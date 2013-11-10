//
//  JSONModel.m
//
//  @version 0.10.0
//  @author Marin Todorov, http://www.touch-code-magazine.com
//

// Copyright (c) 2012-2013 Marin Todorov, Underplot ltd.
// This code is distributed under the terms and conditions of the MIT license.
//
// Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
// The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
//
// The MIT License in plain English: http://www.touch-code-magazine.com/JSONModel/MITLicense

#if !__has_feature(objc_arc)
#error The JSONMOdel framework is ARC only, you can enable ARC on per file basis.
#endif


#import <objc/runtime.h>
#import <objc/message.h>

#import "JSONModel.h"
#import "JSONModelClassProperty.h"
#import "JSONModelArray.h"

#pragma mark - associated objects names
static const char * kMapperObjectKey;
static const char * kClassPropertiesKey;
static const char * kClassRequiredPropertyNamesKey;
static const char * kIndexPropertyNameKey;

#pragma mark - class static variables
static NSArray* allowedJSONTypes = nil;
static NSArray* allowedPrimitiveTypes = nil;
static JSONValueTransformer* valueTransformer = nil;

#pragma mark - model cache
static JSONKeyMapper* globalKeyMapper = nil;

#pragma mark - JSONModel implementation
@implementation JSONModel

#pragma mark - initialization methods

+(void)load
{
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        // initialize all class static objects,
        // which are common for ALL JSONModel subclasses
        
		@autoreleasepool {
            allowedJSONTypes = @[
                [NSString class], [NSNumber class], [NSArray class], [NSDictionary class], [NSNull class], //immutable JSON classes
                [NSMutableString class], [NSMutableArray class], [NSMutableDictionary class] //mutable JSON classes
            ];
            
            allowedPrimitiveTypes = @[
                @"BOOL", @"float", @"int", @"long", @"double", @"short",
                //and some famous aliases
                @"NSInteger", @"NSUInteger"
            ];
            
            valueTransformer = [[JSONValueTransformer alloc] init];
		}
    });
}

-(void)__setup__
{
    //if first instance of this model, generate the property list
    if (!objc_getAssociatedObject(self.class, &kClassPropertiesKey)) {
        [self __inspectProperties];
    }

    //if there's a custom key mapper, store it in the associated object
    id mapper = [[self class] keyMapper];
    if ( mapper && !objc_getAssociatedObject(self.class, &kMapperObjectKey) ) {
        objc_setAssociatedObject(
                                 self.class,
                                 &kMapperObjectKey,
                                 mapper,
                                 OBJC_ASSOCIATION_RETAIN // This is atomic
                                 );
    }
}

-(id)init
{
    self = [super init];
    if (self) {
        //do initial class setup
        [self __setup__];
    }
    return self;
}

-(id)initWithString:(NSString*)string error:(JSONModelError**)err
{
    JSONModelError* initError = nil;
    id objModel = [self initWithString:string usingEncoding:NSUTF8StringEncoding error:&initError];
    if (initError && err) *err = initError;
    return objModel;
}

-(id)initWithString:(NSString *)string usingEncoding:(NSStringEncoding)encoding error:(JSONModelError**)err
{
    //check for nil input
    if (!string) {
        if (err) *err = [JSONModelError errorInputIsNil];
        return nil;
    }
    
    //read the json
    JSONModelError* initError = nil;
    id obj = [NSJSONSerialization JSONObjectWithData:[string dataUsingEncoding:encoding]
                                             options:kNilOptions
                                               error:&initError];

    if (initError) {
        if (err) *err = [JSONModelError errorBadJSON];
        return nil;
    }
    
    //init with dictionary
    id objModel = [self initWithDictionary:obj error:&initError];
    if (initError && err) *err = initError;
    return objModel;
}

-(id)initWithDictionary:(NSDictionary*)dict error:(NSError**)err
{
    //check for nil input
    if (!dict) {
        if (err) *err = [JSONModelError errorInputIsNil];
        return nil;
    }

    //invalid input, just create empty instance
    if (![dict isKindOfClass:[NSDictionary class]]) {
        if (err) *err = [JSONModelError errorInvalidDataWithMessage:@"Attempt to initialize JSONModel object using initWithDictionary:error: but the dictionary parameter was not an 'NSDictionary'."];
        return nil;
    }

    //create a class instance
    self = [super init];
    if (!self) {
        
        //super init didn't succeed
        if (err) *err = [JSONModelError errorModelIsInvalid];
        return nil;
    }
    
    
    //do initial class setup, inspect properties
    [self __setup__];
    
    //check if all required properties are present
    NSArray* incomingKeysArray = [dict allKeys];
    NSMutableSet* requiredProperties = [self __requiredPropertyNames];
    NSSet* incomingKeys = [NSSet setWithArray: incomingKeysArray];
    
    //get the model key mapper
    JSONKeyMapper* keyMapper = objc_getAssociatedObject(self.class, &kMapperObjectKey);
    
    //if no custom mapper, check for a global mapper
    if (keyMapper==nil && globalKeyMapper!=nil) keyMapper = globalKeyMapper;
    
    //transform the key names, if neccessary
    if (keyMapper) {

        NSMutableSet* transformedIncomingKeys = [NSMutableSet setWithCapacity: requiredProperties.count];
        NSString* transformedName = nil;

        //loop over the required properties list
        for (JSONModelClassProperty* property in [self __properties__]) {

            //get the mapped key path
            transformedName = keyMapper.modelToJSONKeyBlock(property.name);
            
            //chek if exists and if so, add to incoming keys
            if ([dict valueForKeyPath:transformedName]) {
                [transformedIncomingKeys addObject: property.name];
            }
        }
        
        //overwrite the raw incoming list with the mapped key names
        incomingKeys = transformedIncomingKeys;
    }
    
    //check for missing input keys
    if (![requiredProperties isSubsetOfSet:incomingKeys]) {

        //get a list of the missing properties
        [requiredProperties minusSet:incomingKeys];

        //not all required properties are in - invalid input
        JMLog(@"Incoming data was invalid [%@ initWithDictionary:]. Keys missing: %@", self.class, requiredProperties);
        
        if (err) *err = [JSONModelError errorInvalidDataWithMissingKeys:requiredProperties];
        return nil;
    }
    
    //not needed anymore
    incomingKeys= nil;
    requiredProperties= nil;
    
    //loop over the incoming keys and set self's properties
    for (JSONModelClassProperty* property in [self __properties__]) {

        //convert key name ot model keys, if a mapper is provided
        NSString* jsonKeyPath = property.name;
        if (keyMapper) jsonKeyPath = keyMapper.modelToJSONKeyBlock( property.name );

        //JMLog(@"keyPath: %@", jsonKeyPath);
        
        //general check for data type compliance
        id jsonValue = [dict valueForKeyPath: jsonKeyPath];
        
        //check for Optional properties
        if (isNull(jsonValue)) {
            //skip this property, continue with next property
            if (property.isOptional==YES) continue;
            
            //null value for required property
            NSString* msg = [NSString stringWithFormat:@"Value of required model key %@ is null", property.name];
            JSONModelError* dataErr = [JSONModelError errorInvalidDataWithMessage:msg];
            *err = [dataErr errorByPrependingKeyPathComponent:property.name];
            
            return nil;
        }
        
        Class jsonValueClass = [jsonValue class];
        BOOL isValueOfAllowedType = NO;
        
        for (Class allowedType in allowedJSONTypes) {
            if ( [jsonValueClass isSubclassOfClass: allowedType] ) {
                isValueOfAllowedType = YES;
                break;
            }
        }
        
        if (isValueOfAllowedType==NO) {
            //type not allowed
            JMLog(@"Type %@ is not allowed in JSON.", NSStringFromClass(jsonValueClass));

            if (err) {
				NSString* msg = [NSString stringWithFormat:@"Type %@ is not allowed in JSON.", NSStringFromClass(jsonValueClass)];
				JSONModelError* dataErr = [JSONModelError errorInvalidDataWithMessage:msg];
				*err = [dataErr errorByPrependingKeyPathComponent:property.name];
			}
            return nil;
        }
                
        //check if there's matching property in the model
        if (property) {
            
            // check for custom setter, than the model doesn't need to do any guessing
            // how to read the property's value from JSON
            if ([self __customSetValue:jsonValue forProperty:property]) {
                //skip to next JSON key
                continue;
            };
            
            // 0) handle primitives
            if (property.type == nil && property.structName==nil) {
                
                //generic setter
                [self setValue:jsonValue forKey: property.name];

                //skip directly to the next key
                continue;
            }
            
            // 0.5) handle nils
            if (isNull(jsonValue)) {
                [self setValue:nil forKey: property.name];
                continue;
            }

            
            // 1) check if property is itself a JSONModel
            if ([[property.type class] isSubclassOfClass:[JSONModel class]]) {
                
                //initialize the property's model, store it
                JSONModelError* initErr = nil;
                id value = [[property.type alloc] initWithDictionary: jsonValue error:&initErr];

                if (!value) {
					// Propagate the error, including the property name as the key-path component
					if((err != nil) && (initErr != nil))
					{
						*err = [initErr errorByPrependingKeyPathComponent:property.name];
					}
                    return nil;
                }
                [self setValue:value forKey: property.name];
                
                //for clarity, does the same without continue
                continue;
                
            } else {
                
                // 2) check if there's a protocol to the property
                //  ) might or not be the case there's a built in transofrm for it
                if (property.protocol) {
                    
                    //JMLog(@"proto: %@", p.protocol);
                    jsonValue = [self __transform:jsonValue forProperty:property error:err];
                    if (!jsonValue) {
                        if ((err != nil) && (*err == nil)) {
							NSString* msg = [NSString stringWithFormat:@"Failed to transform value, but no error was set during transformation. (%@)", property];
							JSONModelError* dataErr = [JSONModelError errorInvalidDataWithMessage:msg];
							*err = [dataErr errorByPrependingKeyPathComponent:property.name];
						}
                        return nil;
                    }
                }
                
                // 3.1) handle matching standard JSON types
                if (property.isStandardJSONType && [jsonValue isKindOfClass: property.type]) {
                    
                    //mutable properties
                    if (property.isMutable) {
                        jsonValue = [jsonValue mutableCopy];
                    }
                    
                    //set the property value
                    [self setValue:jsonValue forKey: property.name];
                    continue;
                }
                
                // 3.3) handle values to transform
                if (
                    (![jsonValue isKindOfClass:property.type] && !isNull(jsonValue))
                    ||
                    //the property is mutable
                    property.isMutable
                    ||
                    //custom struct property
                    property.structName
                    ) {
                    
                    // searched around the web how to do this better
                    // but did not find any solution, maybe that's the best idea? (hardly)
                    Class sourceClass = [JSONValueTransformer classByResolvingClusterClasses:[jsonValue class]];
                    
                    //JMLog(@"to type: [%@] from type: [%@] transformer: [%@]", p.type, sourceClass, selectorName);
                    
                    //build a method selector for the property and json object classes
                    NSString* selectorName = [NSString stringWithFormat:@"%@From%@:",
                                              (property.structName? property.structName : property.type), //target name
                                              sourceClass]; //source name
                    SEL selector = NSSelectorFromString(selectorName);
                    
                    //check if there's a transformer with that name
                    if ([valueTransformer respondsToSelector:selector]) {
                        
                        //it's OK, believe me...
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
                        //transform the value
                        jsonValue = [valueTransformer performSelector:selector withObject:jsonValue];
#pragma clang diagnostic pop
                        
                        [self setValue:jsonValue forKey: property.name];
                        
                    } else {
                        
                        // it's not a JSON data type, and there's no transformer for it
                        // if property type is not supported - that's a programmer mistaked -> exception
                        @throw [NSException exceptionWithName:@"Type not allowed"
                                                       reason:[NSString stringWithFormat:@"%@ type not supported for %@.%@", property.type, [self class], property.name]
                                                     userInfo:nil];
                        return nil;
                    }
                    
                } else {
                    // 3.4) handle "all other" cases (if any)
                    [self setValue:jsonValue forKey: property.name];
                }
            }
        }
    }
    
    //run any custom model validation
    NSError* validationError = nil;
    BOOL doesModelDataValidate = [self validate:&validationError];
    
    if (doesModelDataValidate == NO) {
        if (err) *err = validationError;
        return nil;
    }
    
    //model is valid! yay!
    return self;
}

#pragma mark - property inspection methods
//returns a set of the required keys for the model
-(NSMutableSet*)__requiredPropertyNames
{
    //fetch the associated property names
    NSMutableSet* classRequiredPropertyNames = objc_getAssociatedObject(self.class, &kClassRequiredPropertyNamesKey);
    
    if (!classRequiredPropertyNames) {
        classRequiredPropertyNames = [NSMutableSet set];
        [[self __properties__] enumerateObjectsUsingBlock:^(JSONModelClassProperty* p, NSUInteger idx, BOOL *stop) {
            if (!p.isOptional) [classRequiredPropertyNames addObject:p.name];
        }];
        
        //persist the list
        objc_setAssociatedObject(
                                 self.class,
                                 &kClassRequiredPropertyNamesKey,
                                 classRequiredPropertyNames,
                                 OBJC_ASSOCIATION_RETAIN // This is atomic
                                 );
    }
    return classRequiredPropertyNames;
}

//returns a list of the model's properties
-(NSArray*)__properties__
{
    //fetch the associated object
    NSDictionary* classProperties = objc_getAssociatedObject(self.class, &kClassPropertiesKey);
    if (classProperties) return [classProperties allValues];

    //if here, the class needs to inspect itself
    [self __setup__];
    
    //return the property list
    classProperties = objc_getAssociatedObject(self.class, &kClassPropertiesKey);
    return [classProperties allValues];
}

//inspects the class, get's a list of the class properties
-(void)__inspectProperties
{
    //JMLog(@"Inspect class: %@", [self class]);
    
    NSMutableDictionary* propertyIndex = [NSMutableDictionary dictionary];
    
    //temp variables for the loops
    Class class = [self class];
    NSScanner* scanner = nil;
    NSString* propertyType = nil;
    
    // inspect inherited properties up to the JSONModel class
    while (class != [JSONModel class]) {
        //JMLog(@"inspecting: %@", NSStringFromClass(class));
        
        unsigned int propertyCount;
        objc_property_t *properties = class_copyPropertyList(class, &propertyCount);
        
        //loop over the class properties
        for (unsigned int i = 0; i < propertyCount; i++) {

            JSONModelClassProperty* p = [[JSONModelClassProperty alloc] init];

            //get property name
            objc_property_t property = properties[i];
            const char *propertyName = property_getName(property);
            p.name = [NSString stringWithUTF8String:propertyName];
            
            //JMLog(@"property: %@", p.name);
            
            //get property attributes
            const char *attrs = property_getAttributes(property);
            NSString* propertyAttributes = [NSString stringWithUTF8String:attrs];
            
            if ([propertyAttributes hasPrefix:@"Tc,"]) {
                //mask BOOLs as structs so they can have custom convertors
                p.structName = @"BOOL";
            }
            
            scanner = [NSScanner scannerWithString: propertyAttributes];
            
            //JMLog(@"attr: %@", [NSString stringWithCString:attrs encoding:NSUTF8StringEncoding]);
            [scanner scanUpToString:@"T" intoString: nil];
            [scanner scanString:@"T" intoString:nil];
            
            //check if the property is an instance of a class
            if ([scanner scanString:@"@\"" intoString: &propertyType]) {
                
                [scanner scanUpToCharactersFromSet:[NSCharacterSet characterSetWithCharactersInString:@"\"<"]
                                        intoString:&propertyType];
                
                //JMLog(@"type: %@", propertyClassName);
                p.type = NSClassFromString(propertyType);
                p.isMutable = ([propertyType rangeOfString:@"Mutable"].location != NSNotFound);
                p.isStandardJSONType = [allowedJSONTypes containsObject:p.type];
                
                //read through the property protocols
                while ([scanner scanString:@"<" intoString:NULL]) {
                    
                    NSString* protocolName = nil;
                    
                    [scanner scanUpToString:@">" intoString: &protocolName];
                    
                    if ([protocolName isEqualToString:@"Optional"]) {
                        p.isOptional = YES;
                    } else if([protocolName isEqualToString:@"Index"]) {
                        p.isIndex = YES;
                        objc_setAssociatedObject(
                                                 self.class,
                                                 &kIndexPropertyNameKey,
                                                 p.name,
                                                 OBJC_ASSOCIATION_RETAIN // This is atomic
                                                 );
                    } else if([protocolName isEqualToString:@"ConvertOnDemand"]) {
                        p.convertsOnDemand = YES;
                    } else if([protocolName isEqualToString:@"Ignore"]) {
                        p = nil;
                    } else {
                        p.protocol = protocolName;
                    }
                    
                    [scanner scanString:@">" intoString:NULL];
                }

            }
            //check if the property is a structure
            else if ([scanner scanString:@"{" intoString: &propertyType]) {
                [scanner scanCharactersFromSet:[NSCharacterSet alphanumericCharacterSet]
                                    intoString:&propertyType];
                
                p.isStandardJSONType = NO;
                p.structName = propertyType;

            }
            //the property must be a primitive
            else {

                //the property contains a primitive data type
                [scanner scanUpToCharactersFromSet:[NSCharacterSet characterSetWithCharactersInString:@","]
                                        intoString:&propertyType];
                
                //get the full name of the primitive type
                propertyType = valueTransformer.primitivesNames[propertyType];
                
                if (![allowedPrimitiveTypes containsObject:propertyType]) {
                    
                    //type not allowed - programmer mistaked -> exception
                    @throw [NSException exceptionWithName:@"JSONModelProperty type not allowed"
                                                   reason:[NSString stringWithFormat:@"Property type of %@.%@ is not supported by JSONModel.", self.class, p.name]
                                                 userInfo:nil];
                }

            }

            if([[self class] propertyIsOptional:[NSString stringWithCString:propertyName encoding:NSUTF8StringEncoding]]){
                    p.isOptional = YES;
            }

            if([[self class] propertyIsIgnored:[NSString stringWithCString:propertyName encoding:NSUTF8StringEncoding]]){
                    p = nil;
            }

            //add the property object to the temp index
            if (p) {
                [propertyIndex setValue:p forKey:p.name];
            }
        }
        
        free(properties);
        
        //ascend to the super of the class
        //(will do that until it reaches the root class - JSONModel)
        class = [class superclass];
    }
    
    //finally store the property index in the static property index
    objc_setAssociatedObject(
                             self.class,
                             &kClassPropertiesKey,
                             [propertyIndex copy],
                             OBJC_ASSOCIATION_RETAIN // This is atomic
                             );
}

#pragma mark - built-in transformer methods
//few built-in transformations
-(id)__transform:(id)value forProperty:(JSONModelClassProperty*)property error:(NSError**)err
{
    Class protocolClass = NSClassFromString(property.protocol);
    if (!protocolClass) {

        //no other protocols on arrays and dictionaries
        //except JSONModel classes
        if ([value isKindOfClass:[NSArray class]]) {
            @throw [NSException exceptionWithName:@"Bad property protocol declaration"
                                           reason:[NSString stringWithFormat:@"<%@> is not allowed JSONModel property protocol, and not a JSONModel class.", property.protocol]
                                         userInfo:nil];
        }
        return value;
    }
    
    //if the protocol is actually a JSONModel class
    if ([[protocolClass class] isSubclassOfClass:[JSONModel class]]) {

        //check if it's a list of models
        if ([property.type isSubclassOfClass:[NSArray class]]) {

			// Expecting an array, make sure 'value' is an array
			if(![[value class] isSubclassOfClass:[NSArray class]])
			{
				if(err != nil)
				{
					NSString* mismatch = [NSString stringWithFormat:@"Property '%@' is declared as NSArray<%@>* but the corresponding JSON value is not a JSON Array.", property.name, property.protocol];
					JSONModelError* typeErr = [JSONModelError errorInvalidDataWithTypeMismatch:mismatch];
					*err = [typeErr errorByPrependingKeyPathComponent:property.name];
				}
				return nil;
			}

            if (property.convertsOnDemand) {
                //on demand conversion
                value = [[JSONModelArray alloc] initWithArray:value modelClass:[protocolClass class]];
                
            } else {
                //one shot conversion
				JSONModelError* arrayErr = nil;
                value = [[protocolClass class] arrayOfModelsFromDictionaries:value error:&arrayErr];
				if((err != nil) && (arrayErr != nil))
				{
					*err = [arrayErr errorByPrependingKeyPathComponent:property.name];
					return nil;
				}
            }
        }
        
        //check if it's a dictionary of models
        if ([property.type isSubclassOfClass:[NSDictionary class]]) {

			// Expecting a dictionary, make sure 'value' is a dictionary
			if(![[value class] isSubclassOfClass:[NSDictionary class]])
			{
				if(err != nil)
				{
					NSString* mismatch = [NSString stringWithFormat:@"Property '%@' is declared as NSDictionary<%@>* but the corresponding JSON value is not a JSON Object.", property.name, property.protocol];
					JSONModelError* typeErr = [JSONModelError errorInvalidDataWithTypeMismatch:mismatch];
					*err = [typeErr errorByPrependingKeyPathComponent:property.name];
				}
				return nil;
			}

            NSMutableDictionary* res = [NSMutableDictionary dictionary];

            for (NSString* key in [value allKeys]) {
				JSONModelError* initErr = nil;
                id obj = [[[protocolClass class] alloc] initWithDictionary:value[key] error:&initErr];
				if (obj == nil)
				{
					// Propagate the error, including the property name as the key-path component
					if((err != nil) && (initErr != nil))
					{
						initErr = [initErr errorByPrependingKeyPathComponent:key];
						*err = [initErr errorByPrependingKeyPathComponent:property.name];
					}
                    return nil;
                }
                [res setValue:obj forKey:key];
            }
            value = [NSDictionary dictionaryWithDictionary:res];
        }
    }

    return value;
}

//built-in reverse transormations (export to JSON compliant objects)
-(id)__reverseTransform:(id)value forProperty:(JSONModelClassProperty*)property
{
    Class protocolClass = NSClassFromString(property.protocol);
    if (!protocolClass) return value;
    
    //if the protocol is actually a JSONModel class
    if ([[protocolClass class] isSubclassOfClass:[JSONModel class]]) {

        //check if should export list of dictionaries
        if (property.type == [NSArray class] || property.type == [NSMutableArray class]) {
            NSMutableArray* tempArray = [NSMutableArray arrayWithCapacity: [(NSArray*)value count] ];
            for (id<AbstractJSONModelProtocol> model in (NSArray*)value) {
                if ([model respondsToSelector:@selector(toDictionary)]) {
                    [tempArray addObject: [model toDictionary]];
                } else
                    [tempArray addObject: model];
            }
            return [tempArray copy];
        }
        
        //check if should export dictionary of dictionaries
        if (property.type == [NSDictionary class] || property.type == [NSMutableDictionary class]) {
            NSMutableDictionary* res = [NSMutableDictionary dictionary];
            for (NSString* key in [(NSDictionary*)value allKeys]) {
                id<AbstractJSONModelProtocol> model = value[key];
                [res setValue: [model toDictionary] forKey: key];
            }
            return [NSDictionary dictionaryWithDictionary:res];
        }
    }
    
    return value;
}

#pragma mark - custom transformations
-(BOOL)__customSetValue:(id<NSObject>)value forProperty:(JSONModelClassProperty*)property
{
    if (property.setterType == kNotInspected) {
        //check for a custom property setter method
        NSString* ucfirstName = [property.name stringByReplacingCharactersInRange:NSMakeRange(0,1)
                                                                       withString:[[property.name substringToIndex:1] uppercaseString]];
        NSString* selectorName = [NSString stringWithFormat:@"set%@With%@:", ucfirstName,
                                  [JSONValueTransformer classByResolvingClusterClasses:[value class]]
                                  ];

        SEL customPropertySetter = NSSelectorFromString(selectorName);
        
        //check if there's a custom selector like this
        if (![self respondsToSelector: customPropertySetter]) {
            property.setterType = kNo;
            return NO;
        }
        
        //cache the custom setter selector
        property.setterType = kCustom;
        property.customSetter = customPropertySetter;
    }
    
    if (property.setterType==kCustom) {
        //call the custom setter
        //https://github.com/steipete
        ((void (*) (id, SEL, id))objc_msgSend)(self, property.customSetter, value);
        return YES;
    }
    
    return NO;
}

-(BOOL)__customGetValue:(id<NSObject>*)value forProperty:(JSONModelClassProperty*)property
{
    if (property.getterType == kNotInspected) {
        //check for a custom property getter method
        NSString* ucfirstName = [property.name stringByReplacingCharactersInRange: NSMakeRange(0,1)
                                                                       withString: [[property.name substringToIndex:1] uppercaseString]];
        NSString* selectorName = [NSString stringWithFormat:@"JSONObjectFor%@", ucfirstName];
        
        SEL customPropertyGetter = NSSelectorFromString(selectorName);
        if (![self respondsToSelector: customPropertyGetter]) {
            property.getterType = kNo;
            return NO;
        }
        
        property.getterType = kCustom;
        property.customGetter = customPropertyGetter;

    }
    
    if (property.getterType==kCustom) {
        //call the custom getter
        #pragma clang diagnostic push
        #pragma clang diagnostic ignored "-Warc-performSelector-leaks"
        *value = [self performSelector:property.customGetter withObject:nil];
        #pragma clang diagnostic pop
        return YES;
    }
    
    return NO;
}

#pragma mark - persistance
-(void)__createDictionariesForKeyPath:(NSString*)keyPath inDictionary:(NSMutableDictionary**)dict
{
    //find if there's a dot left in the keyPath
    NSUInteger dotLocation = [keyPath rangeOfString:@"."].location;
    if (dotLocation==NSNotFound) return;
    
    //inspect next level
    NSString* nextHierarchyLevelKeyName = [keyPath substringToIndex: dotLocation];
    NSDictionary* nextLevelDictionary = [*dict objectForKey:nextHierarchyLevelKeyName];

    if (nextLevelDictionary==nil) {
        //create non-existing next level here
        nextLevelDictionary = [NSMutableDictionary dictionary];
    }
    
    //recurse levels
    [self __createDictionariesForKeyPath:[keyPath substringFromIndex: dotLocation+1]
                            inDictionary:&nextLevelDictionary ];
    
    //create the hierarchy level
    [*dict setValue:nextLevelDictionary  forKeyPath: nextHierarchyLevelKeyName];
}

//exports the model as a dictionary of JSON compliant objects
-(NSDictionary*)toDictionary
{
    NSArray* properties = [self __properties__];
    NSMutableDictionary* tempDictionary = [NSMutableDictionary dictionaryWithCapacity:properties.count];

    id value;

    //get the key mapper
    JSONKeyMapper* keyMapper = objc_getAssociatedObject(self.class, &kMapperObjectKey);
    
    //if no custom mapper, check for a global mapper
    if (keyMapper==nil && globalKeyMapper!=nil) keyMapper = globalKeyMapper;

    //loop over all properties
    for (JSONModelClassProperty* p in properties) {
        
        //fetch key and value
        NSString* keyPath = p.name;
        value = [self valueForKey: p.name];
        
        //convert the key name, if a key mapper exists
        if (keyMapper) keyPath = keyMapper.modelToJSONKeyBlock(keyPath);

        //JMLog(@"toDictionary[%@]->[%@] = '%@'", p.name, keyPath, value);

        if ([keyPath rangeOfString:@"."].location != NSNotFound) {
            //there are sub-keys, introduce dictionaries for them
            [self __createDictionariesForKeyPath:keyPath inDictionary:&tempDictionary];
        }
        
        //check for custom getter
        if ([self __customGetValue:&value forProperty:p]) {
            //custom getter, all done
            [tempDictionary setValue:value forKey:keyPath];
            continue;
        }
        
        //export nil when they are not optional values as JSON null, so that the structure of the exported data
        //is still valid if it's to be imported as a model again
        if (isNull(value)) {
            
            if (p.isOptional)
            {
                [tempDictionary removeObjectForKey:keyPath];
            }
            else
            {
                [tempDictionary setValue:[NSNull null] forKeyPath:keyPath];
            }
            continue;
        }
        
        //check if the property is another model
        if ([value isKindOfClass:[JSONModel class]]) {

            //recurse models
            value = [(JSONModel*)value toDictionary];
            [tempDictionary setValue:value forKeyPath: keyPath];
            
            //for clarity
            continue;
            
        } else {
            
            // 1) check for built-in transformation
            if (p.protocol) {
                value = [self __reverseTransform:value forProperty:p];
            }
            
            // 2) check for standard types OR 2.1) primitives
            if (p.structName==nil && (p.isStandardJSONType || p.type==nil)) {

                //generic get value
                [tempDictionary setValue:value forKeyPath: keyPath];
                
                continue;
            }
            
            // 3) try to apply a value transformer
            if (YES) {
                
                //create selector from the property's class name
                NSString* selectorName = [NSString stringWithFormat:@"%@From%@:", @"JSONObject", p.type?p.type:p.structName];
                SEL selector = NSSelectorFromString(selectorName);
                
                //check if there's a transformer declared
                if ([valueTransformer respondsToSelector:selector]) {
                    
                    //it's OK, believe me...
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
                    value = [valueTransformer performSelector:selector withObject:value];
#pragma clang diagnostic pop
                    
                    [tempDictionary setValue:value forKeyPath: keyPath];
                    
                } else {

                    //in this case most probably a custom property was defined in a model
                    //but no default reverse transofrmer for it
                    @throw [NSException exceptionWithName:@"Value transformer not found"
                                                   reason:[NSString stringWithFormat:@"[JSONValueTransformer %@] not found", selectorName]
                                                 userInfo:nil];
                    return nil;
                }
            }
        }
    }
    
    return [tempDictionary copy];
}

//exports model to a dictionary and then to a JSON string
-(NSString*)toJSONString
{
    NSData* jsonData = nil;
    NSError* jsonError = nil;
    
    @try {
        NSDictionary* dict = [self toDictionary];
        jsonData = [NSJSONSerialization dataWithJSONObject:dict options:kNilOptions error:&jsonError];
    }
    @catch (NSException *exception) {
        //this should not happen in properly design JSONModel
        //usually means there was no reverse transformer for a custom property
        JMLog(@"EXCEPTION: %@", exception.description);
        return nil;
    }
    
    return [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
}

#pragma mark - import/export of lists
//loop over an NSArray of JSON objects and turn them into models
+(NSMutableArray*)arrayOfModelsFromDictionaries:(NSArray*)array
{
	return [self arrayOfModelsFromDictionaries:array error:nil];
}

// Same as above, but with error reporting
+(NSMutableArray*)arrayOfModelsFromDictionaries:(NSArray*)array error:(NSError**)err
{
    //bail early
    if (isNull(array)) return nil;

    //parse dictionaries to objects
    NSMutableArray* list = [NSMutableArray arrayWithCapacity: [array count]];

    for (NSDictionary* d in array) {

		JSONModelError* initErr = nil;
		id obj = [[self alloc] initWithDictionary:d error:&initErr];
		if (obj == nil)
		{
			// Propagate the error, including the array index as the key-path component
			if((err != nil) && (initErr != nil))
			{
				NSString* path = [NSString stringWithFormat:@"[%lu]", (unsigned long)list.count];
				*err = [initErr errorByPrependingKeyPathComponent:path];
			}
			return nil;
		}

        [list addObject: obj];
    }

    return list;
}

//loop over NSArray of models and export them to JSON objects
+(NSMutableArray*)arrayOfDictionariesFromModels:(NSArray*)array
{
    //bail early
    if (isNull(array)) return nil;

    //convert to dictionaries
    NSMutableArray* list = [NSMutableArray arrayWithCapacity: [array count]];
    
    for (id<AbstractJSONModelProtocol> object in array) {
        
        id obj = [object toDictionary];
        if (!obj) return nil;
        
        [list addObject: obj];
    }
    return list;
}

#pragma mark - custom comparison methods
-(NSString*)indexPropertyName
{
    //custom getter for an associated object
    return objc_getAssociatedObject(self.class, &kIndexPropertyNameKey);
}

-(BOOL)isEqual:(id)object
{
    //bail early if different classes
    if (![object isMemberOfClass:[self class]]) return NO;
    
    if (self.indexPropertyName) {
        //there's a defined ID property
        id objectId = [object valueForKey: self.indexPropertyName];
        return [[self valueForKey: self.indexPropertyName] isEqual:objectId];
    }
    
    //default isEqual implementation
    return [super isEqual:object];
}

-(NSComparisonResult)compare:(id)object
{
    if (self.indexPropertyName) {
        id objectId = [object valueForKey: self.indexPropertyName];
        if ([objectId respondsToSelector:@selector(compare:)]) {
            return [[self valueForKey:self.indexPropertyName] compare:objectId];
        }
    }

    //on purpose postponing the asserts for speed optimization
    //these should not happen anyway in production conditions
    NSAssert(self.indexPropertyName, @"Can't compare models with no <Index> property");
    NSAssert1(NO, @"The <Index> property of %@ is not comparable class.", [self class]);
    return kNilOptions;
}

- (NSUInteger)hash
{
    if (self.indexPropertyName) {
        return [self.indexPropertyName hash];
    }
    
    return [super hash];
}

#pragma mark - custom data validation
-(BOOL)validate:(NSError**)error
{
    return YES;
}

#pragma mark - custom recursive description
//custom description method for debugging purposes
-(NSString*)description
{
    NSMutableString* text = [NSMutableString stringWithFormat:@"<%@> \n", [self class]];
    
    for (JSONModelClassProperty *p in [self __properties__]) {
        id value = [self valueForKey:p.name];
        NSString* valueDescription = (value)?[value description]:@"<nil>";
        
        if (p.isStandardJSONType && ![value respondsToSelector:@selector(count)] && [valueDescription length]>60 && !p.convertsOnDemand) {

            //cap description for longer values
            valueDescription = [NSString stringWithFormat:@"%@...", [valueDescription substringToIndex:59]];
        }
        valueDescription = [valueDescription stringByReplacingOccurrencesOfString:@"\n" withString:@"\n   "];
        [text appendFormat:@"   [%@]: %@\n", p.name, valueDescription];
    }
    
    [text appendFormat:@"</%@>", [self class]];
    return text;
}

#pragma mark - key mapping
+(JSONKeyMapper*)keyMapper
{
    return nil;
}

+(void)setGlobalKeyMapper:(JSONKeyMapper*)globalKeyMapperParam
{
    globalKeyMapper = globalKeyMapperParam;
}

+(BOOL)propertyIsOptional:(NSString*)propertyName
{
    return NO;
}

+(BOOL)propertyIsIgnored:(NSString *)propertyName
{
    return NO;
}

@end
