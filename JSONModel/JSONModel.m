//
//  JSONModel.m
//
//  @version 0.7
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

#pragma mark - exceptions
@implementation JSONModelException @end
@implementation JSONModelTypeNotAllowedException @end
@implementation JSONModelInvalidDataException @end

#pragma mark JSONModelClassProperty
@implementation JSONModelClassProperty
@end

#pragma mark - class static variables
static NSArray* allowedTypes = nil;
static NSMutableDictionary* classProperties = nil;
static NSMutableDictionary* classRequiredPropertyNames = nil;

static JSONValueTransformer* valueTransformer = nil;

#pragma mark - JSONModel implementation
@implementation JSONModel
{
    NSString* _className;
}

#pragma mark - initialization methods

+(void)initialize
{
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        //initialize all class static objects
        
        allowedTypes = @[
          /* strings */  @"NSString",@"NSMutableString",@"__NSCFString",@"__NSCFConstantString",
          /* numbers */  @"NSNumber",@"NSDecimalNumber",@"__NSCFNumber", @"__NSCFBoolean",
          /* arrays */   @"NSArray", @"NSMutableArray", @"__NSArrayM", @"__NSArrayI",@"__NSCFArray",
          /* dictionaries */  @"NSDictionary",@"NSMutableDictionary",@"__NSDictionaryM",@"__NSDictionaryI",@"__NSCFDictionary",
          /* null */     @"NSNull",
          /* primitives */    @"BOOL", @"float", @"int", @"long", @"double", @"short"
        ];
        
        classProperties = [NSMutableDictionary dictionary];
        classRequiredPropertyNames = [NSMutableDictionary dictionary];
        valueTransformer = [[JSONValueTransformer alloc] init];
    });
}

-(void)_setup
{
    //minimum setup for the instance
    _className = NSStringFromClass([self class]);
    [self _restrospectProperties];
}

-(id)init
{
    self = [super init];
    if (self) {
        //do initial class setup
        [self _setup];
    }
    return self;
}

-(id)initWithString:(NSString*)s
{
    return [self initWithString:s usingEncoding:NSUTF8StringEncoding];
}

-(id)initWithString:(NSString *)s usingEncoding:(NSStringEncoding)encoding
{
    //let exceptions bubble up
    id obj = [NSJSONSerialization JSONObjectWithData:[s dataUsingEncoding:encoding]
                                             options:kNilOptions
                                               error:nil];
    return [self initWithDictionary:obj];
}

-(id)initWithDictionary:(NSDictionary*)d
{
    //invalid input, just create empty instance
    if (!d) return nil;

    //check for valid parameters
    self = [super init];
    
    if (self) {
        
        //do initial class setup, retrospec properties
        [self _setup];
        
        //check if all required properties are present
        NSArray* incomingKeysArray = [d allKeys];
        NSMutableSet* requiredProperties = [self _requiredPropertyNames];
        NSSet* incomingKeys = [NSSet setWithArray: incomingKeysArray];
        
        if (![requiredProperties isSubsetOfSet:incomingKeys]) {

            //get a list of the missing properties
            [requiredProperties minusSet:incomingKeys];

            //not all required properties are in - invalid input
            @throw [JSONModelInvalidDataException exceptionWithName:@"JSONModelInvalidDataException"
                                                             reason:[NSString stringWithFormat:@"Incoming data was invalid [%@ initWithDictionary:]. Keys missing: %@", _className, requiredProperties]
                                                           userInfo:nil];
            return nil;
        }
        
        //not needed anymore
        incomingKeys= nil;
        requiredProperties= nil;
        
        //loop over the incoming keys and set self's properties
        for (NSString* key in incomingKeysArray) {
            
            //NSLog(@"key: %@", key);
            
            //general check for data type compliance
            id jsonValue = d[key];
            NSString* jsonClassName = NSStringFromClass([jsonValue class]);
            
            if (![allowedTypes containsObject:jsonClassName]) {
                //type not allowed
                @throw [JSONModelTypeNotAllowedException exceptionWithName:@"JSONModelTypeNotAllowedException"
                                                                    reason:[NSString stringWithFormat:@"Type %@ is not allowed in JSON.", jsonClassName]
                                                                  userInfo:nil];
                return nil;
            }
            
            //check if there's matching property in the model
            JSONModelClassProperty* property = classProperties[_className][key];
            
            if (property) {
                
                //get the property class
                Class propertyClass = NSClassFromString(property.type);
                
                // 0) handle primitives
                if (propertyClass == nil) {
                    
                    //just copy the value
                    [self setValue:jsonValue forKey:key];
                    
                    //skip directly to the next key
                    continue;
                }
                
                // 0.5) handle nils
                if (isNull(jsonValue)) {
                    [self setValue:nil forKey:key];
                    continue;
                }

                
                // 1) check if property is itself a JSONModel
                if ([[propertyClass class] isSubclassOfClass:[JSONModel class]]) {
                    
                    //initialize the property's model, store it
                    id value = [[[propertyClass class] alloc] initWithDictionary: jsonValue];
                    [self setValue:value forKey:key];
                    
                    //for clarity, does the same without continue
                    continue;
                    
                } else {
                    
                    // 2) check if there's a protocol to the property
                    //  ) might or not be the case there's a built in transofrm for it
                    if (property.protocol) {
                        
                        //NSLog(@"proto: %@", p.protocol);
                        jsonValue = [self _transform:jsonValue forProperty:property];
                    }
                    
                    // 3) check if it's NOT a standard JSON data type
                    //  ) if so, try to transform it
                    //  ) OR if both values are JSON types BUT they are different
                    //  ) OR it's a MUTABLE property
                    if (
                        //value is not a standard JSON type
                        ![allowedTypes containsObject:property.type]
                        ||
                        //value type mismatch and is NOT null
                        (![jsonValue isKindOfClass:propertyClass] && !isNull(jsonValue))
                        ||
                        //the property is mutable
                        [property.type rangeOfString:@"Mutable"].location != NSNotFound
                        ) {
                        
                        //TODO: searched around the web how to do this better
                        // but did not find any solution, maybe that's the best idea? (hardly)
                        Class sourceClass = [JSONValueTransformer classByResolvingClusterClasses:[jsonValue class]];
                        
                        //NSLog(@"to type: %@", p.type);
                        //NSLog(@"from type: %@", sourceClass);
                        //NSLog(@"transformer: %@", selectorName);
                        
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
                            
                            [self setValue:jsonValue forKey:key];
                            
                        } else {
                            
                            // it's not a JSON data type, and there's no transformer for it - exception
                            @throw [JSONModelTypeNotAllowedException exceptionWithName:@"Type not allowed"
                                                                                reason:[NSString stringWithFormat:@"%@ type not supported for %@.%@", property.type, [self class], property.name]
                                                                              userInfo:nil];
                            return nil;
                        }
                        
                    } else {
                        
                        // OK: it's a compliant value, there's no transformers and other shizzle,
                        // just copy the value
                        [self setValue:jsonValue forKey:key];
                    }
                }
            }
        }
    }
    
    return self;
}

#pragma mark - property restrospection methods
//returns a set of the required keys for the model
-(NSMutableSet*)_requiredPropertyNames
{
    if (!classRequiredPropertyNames[_className]) {
        classRequiredPropertyNames[_className] = [NSMutableSet set];
        [[self _properties] enumerateObjectsUsingBlock:^(JSONModelClassProperty* p, NSUInteger idx, BOOL *stop) {
            if (!p.isOptional) [classRequiredPropertyNames[_className] addObject:p.name];
        }];
    }
    return classRequiredPropertyNames[_className];
}

//returns a list of the model's properties
-(NSArray*)_properties
{
    if (classProperties[_className]) return [classProperties[_className] allValues];
    [self _restrospectProperties];
    return [classProperties[_className] allValues];
}

//retrospects the class, get's a list of the class properties
-(void)_restrospectProperties
{
    NSMutableDictionary* propertyIndex = [NSMutableDictionary dictionary];
    
    Class class = [self class];
    
    // retrospect inherited properties up to the JSONModel class
    while (class != [JSONModel class]) {
        //NSLog(@"retrospecting: %@", NSStringFromClass(class));
        
        unsigned int propertyCount;
        objc_property_t *properties = class_copyPropertyList(class, &propertyCount);
        
        //loop over the class properties
        for (int i = 0; i < propertyCount; i++) {
            
            JSONModelClassProperty* p = [[JSONModelClassProperty alloc] init];

            //get property name
            objc_property_t property = properties[i];
            const char *propertyName = property_getName(property);
            p.name = [NSString stringWithCString:propertyName encoding:NSUTF8StringEncoding];
            
            //NSLog(@"property: %@", p.name);
            
            //get property attributes
            const char *attrs = property_getAttributes(property);
            
            NSScanner *scanner= [NSScanner scannerWithString:
                                 [NSString stringWithCString:attrs encoding:NSUTF8StringEncoding]
                                 ];
            
            NSLog(@"attr: %@", [NSString stringWithCString:attrs encoding:NSUTF8StringEncoding]);
            
            NSString* propertyType = nil;
            
            [scanner scanUpToString:@"T" intoString: nil];
            [scanner scanString:@"T" intoString:nil];
            
            NSString* isObject = nil;
            [scanner scanString:@"@\"" intoString: &isObject];
            
            //check if the property is an instance of a class
            if (isObject) {
                
                //fetch the class name
                [scanner scanUpToCharactersFromSet:[NSCharacterSet characterSetWithCharactersInString:@"\"<"]
                                        intoString:&propertyType];
                
                //NSLog(@"type: %@", propertyClassName);
                p.type = propertyType;
                
                //read through the property protocols
                while ([scanner scanString:@"<" intoString:NULL]) {
                    
                    NSString* protocolName = nil;
                    
                    [scanner scanUpToString:@">" intoString: &protocolName];
                    if ([protocolName isEqualToString:@"Optional"]) {
                        p.isOptional = YES;
                    } else {
                        p.protocol = protocolName;
                    }
                    [scanner scanString:@">" intoString:NULL];
                }

            } else {

                //the property contains a primitive data type
                [scanner scanUpToCharactersFromSet:[NSCharacterSet characterSetWithCharactersInString:@","]
                                        intoString:&propertyType];
                
                //get the primitive type name out of the allowed primitive types index
                p.type = valueTransformer.primitivesNames[propertyType];
                if (!p.type) {
                    
                    //type not allowed
                    @throw [JSONModelTypeNotAllowedException exceptionWithName:@"JSONModelPropertyTypeNotAllowedException"
                                                                        reason:[NSString stringWithFormat:@"Property type of %@.%@ is not supported by JSONModel.", _className, p.name]
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
    classProperties[_className] = propertyIndex;
}

#pragma mark - built-in transformer methods
//few built-in transformations
-(id)_transform:(id)value forProperty:(JSONModelClassProperty*)p
{
    Class protocolClass = NSClassFromString(p.protocol);
    if (!protocolClass) return value;
    
    //if the protocol is actually a JSONModel class
    if ([[protocolClass class] isSubclassOfClass:[JSONModel class]]) {

        //check if it's a list of models
        if ([p.type isEqualToString:@"NSArray"]) {
            value = [[protocolClass class] arrayOfObjectsFromDictionaries: value];
        }
        
        //check if it's a dictionary of models
        if ([p.type isEqualToString:@"NSDictionary"]) {
            NSMutableDictionary* res = [NSMutableDictionary dictionary];
            for (NSString* key in [value allKeys]) {
                id obj = [[[protocolClass class] alloc] initWithDictionary:value[key]];
                [res setValue:obj forKey:key];
            }
            value = [NSDictionary dictionaryWithDictionary:res];
        }
    }

    return value;
}

//built-in reverse transormations (export to JSON compliant objects)
-(id)_reverseTransform:(id)value forProperty:(JSONModelClassProperty*)p
{
    Class protocolClass = NSClassFromString(p.protocol);
    if (!protocolClass) return value;
    
    //if the protocol is actually a JSONModel class
    if ([[protocolClass class] isSubclassOfClass:[JSONModel class]]) {

        //check if should export list of dictionaries
        if ([p.type isEqualToString:@"NSArray"]) {

            NSMutableArray* tempArray = [NSMutableArray arrayWithCapacity: [(NSArray*)value count] ];
            for (id<AbstractJSONModelProtocol> model in (NSArray*)value) {
                [tempArray addObject: [model toDictionary] ];
            }
            return [NSArray arrayWithArray: tempArray];
        }
        
        //check if should export dictionary of dictionaries
        if ([p.type isEqualToString:@"NSDictionary"]) {
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
//exports the model as a dictionary of JSON compliant objects
-(NSDictionary*)toDictionary
{
    
    NSArray* properties = [self _properties];
    NSMutableDictionary* tempDictionary = [NSMutableDictionary dictionaryWithCapacity:properties.count];

    //loop over all properties
    for (JSONModelClassProperty* p in properties) {
        
        id value = [self valueForKey: p.name];

        //skip nil values
        //TODO: should it rather skip nil values, or export null values?
        if (!value) continue;
        
        //check if the property is another model
        if ([value isKindOfClass:[JSONModel class]]) {

            //recurse models
            value = [(JSONModel*)value toDictionary];
            [tempDictionary setValue:value forKey: p.name];
            
            //for clarity
            continue;
            
        } else {
            
            //check if the value is not in the list of handled class types
            if (![allowedTypes containsObject:p.type]) {
                
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
                    
                    [tempDictionary setValue:value forKey: p.name];
                    
                } else {

                    //in this case most probably a custom property was defined in a model
                    //but no default reverse transofrmer for it
                    @throw [JSONModelTypeNotAllowedException exceptionWithName:@"Value transformer not found"
                                                                        reason:[NSString stringWithFormat:@"[JSONValueTransformer %@] not found", selectorName]
                                                                      userInfo:nil];
                    return nil;
                }
                
                
                
            } else {

                //check for built-in transformation
                if (p.protocol) {
                    value = [self _reverseTransform:value forProperty:p];
                }
                
                //straight JSON value - copy over
                [tempDictionary setValue:value forKey: p.name];
            }
            
        }
        
    }
    
    return [NSDictionary dictionaryWithDictionary: tempDictionary];
}

//exports model to a dictionary and then to a JSON string
-(NSString*)toJSONString
{
    //let exceptions bubble up
    NSData* jsonData = [NSJSONSerialization dataWithJSONObject:[self toDictionary] options:kNilOptions error:nil];
    return [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
}

#pragma mark - import/export of lists
//loop over an NSArray of JSON objects and turn them into models
+(NSMutableArray*)arrayOfObjectsFromDictionaries:(NSArray*)a
{
    //bail early
    if (isNull(a)) {
        return [NSMutableArray array];
    }
    
    //parse dictionaries to objects
    NSMutableArray* list = [NSMutableArray arrayWithCapacity: [a count]];
    
    for (NSDictionary* d in a) {
        [list addObject:
         [[self alloc] initWithDictionary: d]
         ];
    }
    
    return list;
}

//loop over NSArray of models and export them to JSON objects
+(NSMutableArray*)arrayOfDictionariesFromObjects:(NSArray*)a
{
    //bail early
    if (isNull(a)) {
        return [NSMutableArray array];
    }
    
    //convert to dictionaries
    NSMutableArray* list = [NSMutableArray arrayWithCapacity: [a count]];
    
    for (id<AbstractJSONModelProtocol> object in a) {
        [list addObject:
         [object toDictionary]
         ];
    }
    return list;
}

#pragma mark - custom recursive description
//custom description method for debugging purposes
-(NSString*)description
{
    NSMutableString* text = [NSMutableString stringWithFormat:@"\n[%@] \n", NSStringFromClass([self class])];
    NSArray* properties = [self _properties];

    for (int i=0;i<properties.count;i++) {
        
        NSString* key = [(JSONModelClassProperty*)properties[i] name];
        id value = [self valueForKey:key];
        NSString* valueDescription = (value)?[value description]:@"<nil>";
        
        if ([valueDescription length]>60) valueDescription = [NSString stringWithFormat:@"%@...", [valueDescription substringToIndex:59]];
        valueDescription = [valueDescription stringByReplacingOccurrencesOfString:@"\n" withString:@"\n   "];
        [text appendFormat:@"   [%@]: %@\n", key, valueDescription];
    }
    
    [text appendFormat:@"[/%@]", NSStringFromClass([self class])];
    return text;
}

@end
