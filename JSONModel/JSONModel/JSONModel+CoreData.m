//
//  JSONModel+CoreData.m
//  JSONModelDemo_iOS
//
//  Created by Marin Todorov on 22/1/14.
//  Copyright (c) 2014 Underplot ltd. All rights reserved.
//

#import "JSONModel+CoreData.h"
#import <objc/runtime.h>
#import <objc/message.h>

@implementation JSONModel(CoreData)

@end

@implementation NSManagedObject(JSONModel)

+(NSString*)entityName
{
    return nil;
}

+(instancetype)entityWithModel:(id<AbstractJSONModelProtocol>)model inContext:(NSManagedObjectContext*)context error:(NSError**)error
{
    return [self entityWithDictionary: [model toDictionary]
                          inContext: context
                              error:error];
}

+(instancetype)entityWithDictionary:(NSDictionary*)dictionary inContext:(NSManagedObjectContext*)context error:(NSError**)error
{
    NSManagedObject* entity = [NSEntityDescription
                               insertNewObjectForEntityForName: self.entityName?self.entityName:NSStringFromClass([self class])
                               inManagedObjectContext:context];
    if (entity) {
        if (![entity updateWithDictionary: dictionary error: error]) {
            return nil;
        }
    }
    return entity;
}

-(BOOL)updateWithDictionary:(NSDictionary*)dictionary error:(NSError**)error
{
    //introspect managed object
    Class class = [self class];
    NSMutableDictionary* moProperties = [@{} mutableCopy];
    
    while (class != [NSManagedObject class]) {
        unsigned int propertyCount;
        objc_property_t *properties = class_copyPropertyList(class, &propertyCount);
        
        //loop over the class properties
        for (unsigned int i = 0; i < propertyCount; i++) {
            objc_property_t property = properties[i];
            const char *propertyName = property_getName(property);

            const char *attrs = property_getAttributes(property);
            NSString* propertyAttributes = @(attrs);
            NSScanner* scanner = [NSScanner scannerWithString: propertyAttributes];
            NSString* propertyType = nil;
            [scanner scanUpToString:@"T" intoString: nil];
            [scanner scanString:@"T" intoString:nil];
            
            //check if the property is an instance of a class
            if ([scanner scanString:@"@\"" intoString: &propertyType]) {
                
                [scanner scanUpToCharactersFromSet:[NSCharacterSet characterSetWithCharactersInString:@"\"<"]
                                        intoString:&propertyType];
            }
            
            moProperties[@(propertyName)] = NSClassFromString(propertyType);
        }
        
        free(properties);
        class = [class superclass];
    }
    
    //validate dictionary keys
    NSArray* dictionaryKeys = [dictionary allKeys];
    for (NSString* key in [moProperties allKeys]) {
        if (![dictionaryKeys containsObject:key]) {
            //unmatched key
            if (error) {
                *error = [JSONModelError errorInvalidDataWithTypeMismatch:[NSString stringWithFormat: @"Key \"%@\" not found in manged object's property list", key]];
            }
            return NO;
        }
    }
    
    //copy values over
    for (NSString* key in [moProperties allKeys]) {
        id value = dictionary[key];

        //exception classes - for core data should be NSDate by default
        if ([[moProperties[key]class] isEqual:[NSDate class]]) {
            SEL NSDateFromNSStringSelector = sel_registerName("NSDateFromNSString:");
            if ([self respondsToSelector:NSDateFromNSStringSelector]) {
                IMP methodImpl = [self methodForSelector:NSDateFromNSStringSelector];
                NSDate * (*method)(id, SEL, NSString *) = (void *)methodImpl;
                //transform the value
                value = method(self, NSDateFromNSStringSelector, dictionary[key]);
            } else {
                value = [self __NSDateFromNSString: dictionary[key]];
            }
        }
        
        //copy the value to the managed object
        [self setValue:value forKey:key];
    }
    
    return YES;
}


#pragma mark - string <-> date
-(NSDate*)__NSDateFromNSString:(NSString*)string
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    string = [string stringByReplacingOccurrencesOfString:@":" withString:@""]; // this is such an ugly code, is this the only way?
    [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HHmmssZZZZ"];
    
    return [dateFormatter dateFromString: string];
}

@end