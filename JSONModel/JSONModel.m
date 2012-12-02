//
//  JSONModel.m
//
//  @version 0.6
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

#pragma mark - type definitions
#pragma mark JSONModelTypeNotAllowedException
@implementation JSONModelTypeNotAllowedException
@end

#pragma mark JSONModelInvalidDataException
@implementation JSONModelInvalidDataException
@end

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
        allowedTypes = @[@"NSString",@"NSNumber",@"NSArray",@"NSDictionary",@"NSMutableArray",@"NSMutableDictionary", @"NSMutableString", @"__NSCFDictionary",@"__NSCFArray", @"__NSCFString", @"__NSCFConstantString", @"__NSCFNumber", @"NSNull", @"BOOL", @"float", @"int", @"long", @"double", @"short", @"__NSCFBoolean"];
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
    //check for valid parameters
    self = [super init];
    if (self) {
        
        //do initial class setup
        [self _setup];
        
        //invalid input, just create empty instance
        if (!d) return self;
        
        //check if all required properties are present
        NSArray* incomingKeysArray = [d allKeys];
        NSMutableSet* requiredProperties = [self _requiredPropertyNames];
        NSSet* incomingKeys = [NSSet setWithArray: incomingKeysArray];
        
        if (![requiredProperties isSubsetOfSet:incomingKeys]) {
            
            //not all required properties are in - invalid input
            [requiredProperties minusSet:incomingKeys];
            @throw [JSONModelInvalidDataException exceptionWithName:@"JSONModelInvalidDataException"
                                                             reason:[NSString stringWithFormat:@"Incoming data was invalid [%@ initWithDictionary:]. Keys missing: %@", _className, requiredProperties]
                                                           userInfo:nil];
            return nil;
        }
        
        incomingKeys= nil;
        requiredProperties= nil;
        
        //loop over the incoming keys and set self's properties
        for (NSString* key in incomingKeysArray) {
            
            //NSLog(@"key: %@", key);
            
            id jsonValue = d[key];
            NSString* jsonClassName = NSStringFromClass([jsonValue class]);
            
            if (![allowedTypes containsObject:jsonClassName]) {
                //type not allowed
                @throw [JSONModelTypeNotAllowedException exceptionWithName:@"JSONModelTypeNotAllowedException"
                                                                    reason:[NSString stringWithFormat:@"Type %@ is not allowed in JSON.", jsonClassName]
                                                                  userInfo:nil];
                return nil;
            }
            
            JSONModelClassProperty* p = classProperties[_className][key];
            
            if (p) {
                
                //get the property class
                Class c = NSClassFromString(p.type);
                
                // 0) handle primitives
                if (c == nil) {
                    
                    //just copy the value
                    [self setValue:jsonValue forKey:key];
                    continue;
                }
                
                // 1) check if property is itself a JSONModel
                if ([[c class] isSubclassOfClass:[JSONModel class]]) {
                    
                    //initialize the property's model, store it
                    id value = [[[c class] alloc] initWithDictionary: jsonValue];
                    [self setValue:value forKey:key];
                    
                } else {
                    
                    // 2) check if there's a protocol to the property
                    //  ) might or not be the case there's a built in transofrm for it
                    //  ) ALSO check if it's a mutable property, if so force a transformer
                    //  ) since all objects come from JSON as non-mutable
                    if (p.protocol) {
                        
                        //NSLog(@"proto: %@", p.protocol);
                        jsonValue = [self _transform:jsonValue forProperty:p];
                    }
                    
                    // 3) check if it's NOT a standard JSON data type
                    //  ) if so, try to transform it
                    //  ) OR if both values are JSON types BUT they are different
                    if (
                        //value is not a standard JSON type
                        ![allowedTypes containsObject:p.type]
                        ||
                        //value type mismatch and is NOT null
                        (![jsonValue isKindOfClass:c] && !isNull(jsonValue))
                        ||
                        //the property is mutable
                        [p.type rangeOfString:@"Mutable"].location != NSNotFound
                        ) {
                        
                        //hack? how to do that better?
                        Class sourceClass = [JSONValueTransformer classByResolvingClusterClasses:[jsonValue class]];
                        
                        //NSLog(@"to type: %@", p.type);
                        //NSLog(@"from type: %@", sourceClass);
                        //NSLog(@"transformer: %@", selectorName);
                        
                        //check for a value transformer
                        NSString* selectorName = [NSString stringWithFormat:@"%@From%@:", p.type, sourceClass];
                        SEL selector = NSSelectorFromString(selectorName);
                        
                        if ([valueTransformer respondsToSelector:selector]) {
                            
                            //it's OK, believe me...
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
                            jsonValue = [valueTransformer performSelector:selector withObject:jsonValue];
#pragma clang diagnostic pop
                            
                            [self setValue:jsonValue forKey:key];
                            
                        } else {
                            // it's not a JSON data type, and there's no transformer for it
                            @throw [JSONModelTypeNotAllowedException exceptionWithName:@"Type not allowed"
                                                                                reason:[NSString stringWithFormat:@"%@ type not supported for %@.%@", p.type, [self class], p.name]
                                                                              userInfo:nil];
                        }
                        
                    } else {
                        
                        //just copy the value
                        [self setValue:jsonValue forKey:key];
                    }
                }
            }
        }
    }
    
    return self;
}

#pragma mark - property restrospection methods
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

-(NSArray*)_properties
{
    if (classProperties[_className]) return [classProperties[_className] allValues];
    [self _restrospectProperties];
    return [classProperties[_className] allValues];
}

-(void)_restrospectProperties
{
    NSMutableDictionary* tempDict = [NSMutableDictionary dictionary];
    
    Class class = [self class];
    while (class != [NSObject class])
    {
        //NSLog(@"retrospecting: %@", NSStringFromClass(class));
        
        unsigned int propertyCount;
        objc_property_t *properties = class_copyPropertyList(class, &propertyCount);
        for (int i = 0; i < propertyCount; i++)
        {
            JSONModelClassProperty* p = [[JSONModelClassProperty alloc] init];

            //get property
            objc_property_t property = properties[i];
            const char *propertyName = property_getName(property);
            NSString *key = [NSString stringWithCString:propertyName encoding:NSUTF8StringEncoding];
            
            //NSLog(@"property: %@", key);
            p.name = key;
            
            const char *attributes = property_getAttributes(property);
            NSString *encoding = [NSString stringWithCString:attributes encoding:NSUTF8StringEncoding];
            
            //NSLog(@"attr: %@", encoding);
            
            NSString* propertyType = nil;
            
            NSScanner *scanner=[NSScanner scannerWithString:encoding];
            [scanner scanUpToString:@"T" intoString: nil];
            [scanner scanString:@"T" intoString:nil];
            
            NSString* isObject = nil;
            [scanner scanString:@"@\"" intoString: &isObject];
            
            if (isObject) {
                
                //the property contains an instance of a class
                //fetch the class name and a protocol if provided
                
                [scanner scanUpToCharactersFromSet:[NSCharacterSet characterSetWithCharactersInString:@"\"<"]
                                        intoString:&propertyType];
                
                //NSLog(@"type: %@", propertyClassName);
                p.type = propertyType;
                
                NSString* protocolName = nil;
                [scanner scanString:@"<" intoString: &protocolName];
                
                if ([protocolName isEqualToString:@"<"]) {
                    [scanner scanUpToString:@">" intoString: &protocolName];
                    
                    if (protocolName) {
                        NSMutableArray* protocols = [NSMutableArray arrayWithArray:
                                                     [protocolName componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@", "]]
                                                     ];
                        
                        if ([protocols indexOfObject:@"Optional"]!=NSNotFound) {
                            p.isOptional = YES;
                            [protocols removeObject:@"Optional"];
                        }
                        
                        //hack .. any better ideas?
                        if (protocols.count>0) {
                            p.protocol = protocols[0];
                        }
                    }
                }

            } else {

                //the property contains a simple data type
                [scanner scanUpToCharactersFromSet:[NSCharacterSet characterSetWithCharactersInString:@","]
                                        intoString:&propertyType];
                
                p.type = valueTransformer.primitivesNames[propertyType];
                if (!p.type) {
                    //type not allowed
                    @throw [JSONModelTypeNotAllowedException exceptionWithName:@"JSONModelPropertyTypeNotAllowedException"
                                                                        reason:[NSString stringWithFormat:@"Property type of %@.%@ is not supported by JSONModel.", _className, p.name]
                                                                      userInfo:nil];
                }
                
            }
            
            
            [tempDict setValue:p forKey:p.name];
        }
        
        free(properties);
        class = [class superclass];
    }
    
    classProperties[_className] = tempDict;
}

#pragma mark - built-in transformer methods
-(id)_transform:(id)value forProperty:(JSONModelClassProperty*)p
{
    Class protocolClass = NSClassFromString(p.protocol);
    
    // is it a list or dictionary of models?
    // then loop over them and make instances
    
    if ([[protocolClass class] isSubclassOfClass:[JSONModel class]]) {
        //special case for sub-modelling
        if ([p.type isEqualToString:@"NSArray"]) {
            value = [[protocolClass class] arrayOfObjectsFromDictionaries: value];
        }
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

-(id)_reverseTransform:(id)value forProperty:(JSONModelClassProperty*)p
{
    Class protocolClass = NSClassFromString(p.protocol);
    if (!protocolClass) return value;
    
    if ([[protocolClass class] isSubclassOfClass:[JSONModel class]]) {
        //special case for sub-modelling
        if ([p.type isEqualToString:@"NSArray"]) {
            //loop over the elements of the array
            //and transform then back
            NSMutableArray* tempArray = [NSMutableArray arrayWithCapacity: [(NSArray*)value count] ];
            for (id<AbstractJSONModelProtocol> model in (NSArray*)value) {
                [tempArray addObject: [model toDictionary] ];
            }
            return [NSArray arrayWithArray: tempArray];
        }
        
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
-(NSDictionary*)toDictionary
{
    NSArray* properties = [self _properties];
    NSMutableDictionary* tempDictionary = [NSMutableDictionary dictionaryWithCapacity:properties.count];

    for (JSONModelClassProperty* p in properties) {
        
        id value = [self valueForKey: p.name];

        //skip nil values
        if (!value) continue;
        
        //recurse properties
        if ([value isKindOfClass:[JSONModel class]]) {

            //recurse models
            value = [(JSONModel*)value toDictionary];
            [tempDictionary setValue:value forKey: p.name];
            
        } else {
            
            if (![allowedTypes containsObject:p.type]) {
                
                //try transoforming the value
                // NSString by default, any other ideas?
                NSString* selectorName = [NSString stringWithFormat:@"%@From%@:", @"JSONObject", p.type];
                SEL selector = NSSelectorFromString(selectorName);
                
                if ([valueTransformer respondsToSelector:selector]) {
                    
                    //it's OK, believe me...
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
                    value = [valueTransformer performSelector:selector withObject:value];
#pragma clang diagnostic pop
                    
                    [tempDictionary setValue:value forKey: p.name];
                    
                } else {
                    
                    @throw [JSONModelTypeNotAllowedException exceptionWithName:@"Value transformer not found"
                                                                        reason:[NSString stringWithFormat:@"[JSONValueTransformer %@] not found", selectorName]
                                                                      userInfo:nil];

                    
                }
                
                
                
            } else {

                //check for built-in transformation
                if (p.protocol) {
                    value = [self _reverseTransform:value forProperty:p];
                }
                
                //straight JSON value - assign
                [tempDictionary setValue:value forKey: p.name];
            }
            
        }
        
    }
    
    return [NSDictionary dictionaryWithDictionary: tempDictionary];
}

-(NSString*)toJSONString
{
    //let exceptions bubble up
    NSData* jsonData = [NSJSONSerialization dataWithJSONObject:[self toDictionary] options:kNilOptions error:nil];
    return [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
}

#pragma mark - import/export of lists
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
-(NSString*)description
{
    NSMutableString* text = [NSMutableString stringWithFormat:@"[%@] ", NSStringFromClass([self class])];
    NSArray* properties = [self _properties];

    for (int i=0;i<properties.count;i++) {
        
        NSString* key = [(JSONModelClassProperty*)properties[i] name];
        id value = [self valueForKey:key];
        NSString* valueDescription = (value)?[value description]:@"<nil>";
        
        if ([valueDescription length]>10) valueDescription = [NSString stringWithFormat:@"%@...", [valueDescription substringToIndex:9]];
        
        [text appendFormat:@"%@: %@", key, valueDescription];
        
        if (i<properties.count-1) {
            [text appendString:@", "];
        }
    }
    
    return text;
}

@end
