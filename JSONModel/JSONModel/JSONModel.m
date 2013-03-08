//
//  JSONModel.m
//
//  @version 0.8.4
//  @author Marin Todorov, http://www.touch-code-magazine.com
//

// Copyright (c) 2012 Marin Todorov, Underplot ltd.
// This code is distributed under the terms and conditions of the MIT license.
//
// Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
// The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
//
// The MIT License in plain English: http://www.touch-code-magazine.com/JSONModel/MITLicense

#import <objc/runtime.h>

#import "JSONModel.h"
#import "JSONModelClassProperty.h"
#import "JSONModelArray.h"

#pragma mark - class static variables
static NSArray* allowedJSONTypes = nil;
static NSArray* allowedPrimitiveTypes = nil;

static JSONValueTransformer* valueTransformer = nil;

#pragma mark - model cache
static NSMutableDictionary* classProperties = nil;
static NSMutableDictionary* classRequiredPropertyNames = nil;
static NSMutableDictionary* classIndexes = nil;

static NSMutableDictionary* keyMappers = nil;

#pragma mark - JSONModel private interface
@interface JSONModel()
@property (strong, nonatomic, readonly) NSString* className;
@end

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
                @"BOOL", @"float", @"int", @"long", @"double", @"short"
            ];
            
            classProperties = [NSMutableDictionary dictionary];
            classRequiredPropertyNames = [NSMutableDictionary dictionary];
            classIndexes = [NSMutableDictionary dictionary];
            valueTransformer = [[JSONValueTransformer alloc] init];
            keyMappers = [NSMutableDictionary dictionary];
		}
    });
}

-(void)__setup__
{
    //fetch the class name for faster access
    _className = NSStringFromClass([self class]);

    //if first instnce of this model, generate the property list
    if (!classProperties[_className]) {
        [self __restrospectProperties];
    }

    //load the class index name
    _indexPropertyName = classIndexes[_className];
    
    //if first instnce of this model, generate the property mapper
    if (!keyMappers[_className]) {
        
        id mapper = [[self class] keyMapper];
        if (mapper) {
            keyMappers[_className] = mapper;
        }
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
        if (err) *err = [JSONModelError errorInvalidData];
        return nil;
    }

    //create a class instance
    self = [super init];
    if (!self) {
        
        //super init didn't succeed
        if (err) *err = [JSONModelError errorModelIsInvalid];
        return nil;
    }
    
    
    //do initial class setup, retrospec properties
    [self __setup__];
    
    //check if all required properties are present
    NSArray* incomingKeysArray = [dict allKeys];
    NSMutableSet* requiredProperties = [self __requiredPropertyNames];
    NSSet* incomingKeys = [NSSet setWithArray: incomingKeysArray];
    
    //get the key mapper
    JSONKeyMapper* keyMapper = keyMappers[_className];
    
    //transform the key names, if neccessary
    if (keyMapper) {

        NSMutableSet* transformedIncomingKeys = [NSMutableSet setWithCapacity: requiredProperties.count];
        NSString* transformedName = nil;

        //loop over the required properties list
        for (NSString* requiredPropertyName in requiredProperties) {

            //get the mapped key path
            transformedName = keyMapper.modelToJSONKeyBlock(requiredPropertyName);
            
            //chek if exists and if so, add to incoming keys
            if ([dict valueForKeyPath:transformedName]) {
                [transformedIncomingKeys addObject: requiredPropertyName];
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
        JMLog(@"Incoming data was invalid [%@ initWithDictionary:]. Keys missing: %@", self.className, requiredProperties);
        
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
        if (jsonValue==nil && property.isOptional==YES) {
            //skip this property, continue with next property
            continue;
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

            if (err) *err = [JSONModelError errorInvalidData];
            return nil;
        }
                
        //check if there's matching property in the model
        //JSONModelClassProperty* property = classProperties[self.className][key];
        
        if (property) {
            
            // 0) handle primitives
            if (property.type == nil) {
                
                //just copy the value
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
                NSError* initError = nil;
                id value = [[property.type alloc] initWithDictionary: jsonValue error:&initError];

                if (!value) {
                    if (initError && err) *err = [JSONModelError errorInvalidData];
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
                    jsonValue = [self __transform:jsonValue forProperty:property];
                    if (!jsonValue) {
                        if (err) *err = [JSONModelError errorInvalidData];
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
                    ) {
                    
                    // searched around the web how to do this better
                    // but did not find any solution, maybe that's the best idea? (hardly)
                    Class sourceClass = [JSONValueTransformer classByResolvingClusterClasses:[jsonValue class]];
                    
                    //JMLog(@"to type: [%@] from type: [%@] transformer: [%@]", p.type, sourceClass, selectorName);
                    
                    //build a method selector for the property and json object classes
                    NSString* selectorName = [NSString stringWithFormat:@"%@From%@:", property.type, sourceClass];
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

#pragma mark - property restrospection methods
//returns a set of the required keys for the model
-(NSMutableSet*)__requiredPropertyNames
{
    if (!classRequiredPropertyNames[self.className]) {
        classRequiredPropertyNames[self.className] = [NSMutableSet set];
        [[self __properties__] enumerateObjectsUsingBlock:^(JSONModelClassProperty* p, NSUInteger idx, BOOL *stop) {
            if (!p.isOptional) [classRequiredPropertyNames[self.className] addObject:p.name];
        }];
    }
    return classRequiredPropertyNames[self.className];
}

//returns a list of the model's properties
-(NSArray*)__properties__
{
    if (classProperties[self.className]) return [classProperties[self.className] allValues];

    if (!self.className) [self __setup__];
    [self __restrospectProperties];
    return [classProperties[self.className] allValues];
}

//retrospects the class, get's a list of the class properties
-(void)__restrospectProperties
{
    //JMLog(@"Retrospect class: %@", [self class]);
    
    NSMutableDictionary* propertyIndex = [NSMutableDictionary dictionary];
    
    //temp variables for the loops
    Class class = [self class];
    NSScanner* scanner = nil;
    NSString* propertyType = nil;
    
    // retrospect inherited properties up to the JSONModel class
    while (class != [JSONModel class]) {
        //JMLog(@"retrospecting: %@", NSStringFromClass(class));
        
        unsigned int propertyCount;
        objc_property_t *properties = class_copyPropertyList(class, &propertyCount);
        
        //loop over the class properties
        for (int i = 0; i < propertyCount; i++) {
            
            JSONModelClassProperty* p = [[JSONModelClassProperty alloc] init];

            //get property name
            objc_property_t property = properties[i];
            const char *propertyName = property_getName(property);
            p.name = [NSString stringWithUTF8String:propertyName];
            
            //JMLog(@"property: %@", p.name);
            
            //get property attributes
            const char *attrs = property_getAttributes(property);
            
            scanner = [NSScanner scannerWithString:
                       [NSString stringWithUTF8String:attrs]
                       ];
            
            //JMLog(@"attr: %@", [NSString stringWithCString:attrs encoding:NSUTF8StringEncoding]);
            [scanner scanUpToString:@"T" intoString: nil];
            [scanner scanString:@"T" intoString:nil];
            
            //check if the property is an instance of a class
            if ([scanner scanString:@"@\"" intoString: &propertyType]) {
                
                [scanner scanCharactersFromSet:[NSCharacterSet alphanumericCharacterSet]
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
                        classIndexes[self.className] = p.name;
                    } else if([protocolName isEqualToString:@"ConvertOnDemand"]) {
                        p.convertsOnDemand = YES;
                    } else {
                        p.protocol = protocolName;
                    }
                    
                    [scanner scanString:@">" intoString:NULL];
                }

            } else {

                //the property contains a primitive data type
                [scanner scanUpToCharactersFromSet:[NSCharacterSet characterSetWithCharactersInString:@","]
                                        intoString:&propertyType];
                
                //get the full name of the primitive type
                propertyType = valueTransformer.primitivesNames[propertyType];
                
                if (![allowedPrimitiveTypes containsObject:propertyType]) {
                    
                    //type not allowed - programmer mistaked -> exception
                    @throw [NSException exceptionWithName:@"JSONModelProperty type not allowed"
                                                   reason:[NSString stringWithFormat:@"Property type of %@.%@ is not supported by JSONModel.", self.className, p.name]
                                                 userInfo:nil];
                }
                
            }
            
            //add the property object to the temp index
            [propertyIndex setValue:p forKey:p.name];
        }
        
        free(properties);
        
        //ascend to the super of the class
        //(will do that until it reaches the root class - JSONModel)
        class = [class superclass];
    }
    
    //finally store the property index in the static property index
    classProperties[self.className] = propertyIndex;
}

#pragma mark - built-in transformer methods
//few built-in transformations
-(id)__transform:(id)value forProperty:(JSONModelClassProperty*)property
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
            
            if (property.convertsOnDemand) {
                //on demand conversion
                value = [[JSONModelArray alloc] initWithArray:value modelClass:[protocolClass class]];
                
            } else {
                //one shot conversion
                value = [[protocolClass class] arrayOfModelsFromDictionaries: value];
            }
        }
        
        //check if it's a dictionary of models
        if ([property.type isSubclassOfClass:[NSDictionary class]]) {
            NSMutableDictionary* res = [NSMutableDictionary dictionary];
            JSONModelError* initErr = nil;
            
            for (NSString* key in [value allKeys]) {
                id obj = [[[protocolClass class] alloc] initWithDictionary:value[key] error:&initErr];
                if (initErr) {
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
        if (property.type == [NSArray class]) {
            NSMutableArray* tempArray = [NSMutableArray arrayWithCapacity: [(NSArray*)value count] ];
            for (id<AbstractJSONModelProtocol> model in (NSArray*)value) {
                [tempArray addObject: [model toDictionary] ];
            }
            return [NSArray arrayWithArray: tempArray];
        }
        
        //check if should export dictionary of dictionaries
        if (property.type == [NSDictionary class]) {
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
    JSONKeyMapper* keyMapper = keyMappers[_className];
    
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
        
        //export nil values as JSON null, so that the structure of the exported data
        //is still valid if it's to be imported as a model again
        if (isNull(value)) {
            
            [tempDictionary setValue:[NSNull null] forKeyPath:keyPath];
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
            if (p.isStandardJSONType || p.type==nil) {
                [tempDictionary setValue:value forKeyPath: keyPath];
                continue;
            }
            
            // 3) try to apply a value transformer
            if (YES) {
                
                //create selector from the property's class name
                NSString* selectorName = [NSString stringWithFormat:@"%@From%@:", @"JSONObject", p.type];
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
    
    return [NSDictionary dictionaryWithDictionary: tempDictionary];
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
    //bail early
    if (isNull(array)) return nil;
    
    //parse dictionaries to objects
    NSMutableArray* list = [NSMutableArray arrayWithCapacity: [array count]];
    JSONModelError* err = nil;
    
    for (NSDictionary* d in array) {
        
        id obj = [[self alloc] initWithDictionary: d error:&err];
        if (!obj) return nil;
        
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
    NSAssert1(NO, @"The <Index> property of %@ is not comparable class.", [self className]);
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
    NSMutableString* text = [NSMutableString stringWithFormat:@"<%@> \n", NSStringFromClass([self class])];
    NSArray* properties = [self __properties__];

    for (int i=0;i<properties.count;i++) {
        
        JSONModelClassProperty* p = (JSONModelClassProperty*)properties[i];

        id value = [self valueForKey:p.name];
        NSString* valueDescription = (value)?[value description]:@"<nil>";
        
        if (p.isStandardJSONType && [valueDescription length]>60 && !p.convertsOnDemand) {

            //cap description for longer values
            valueDescription = [NSString stringWithFormat:@"%@...", [valueDescription substringToIndex:59]];
        }
        valueDescription = [valueDescription stringByReplacingOccurrencesOfString:@"\n" withString:@"\n   "];
        [text appendFormat:@"   [%@]: %@\n", p.name, valueDescription];
    }
    
    [text appendFormat:@"</%@>", NSStringFromClass([self class])];
    return text;
}

#pragma mark - key mapping
+(JSONKeyMapper*)keyMapper
{
    return nil;
}

@end
