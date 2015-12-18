//
//  JSONKeyMapper.m
//
//  @version 1.2
//  @author Marin Todorov (http://www.underplot.com) and contributors
//

// Copyright (c) 2012-2015 Marin Todorov, Underplot ltd.
// This code is distributed under the terms and conditions of the MIT license.
//
// Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
// The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
//


#import "JSONKeyMapper.h"
#import <libkern/OSAtomic.h>

@interface JSONKeyMapper()
@property (nonatomic, strong) NSMutableDictionary *toModelMap;
@property (nonatomic, strong) NSMutableDictionary *toJSONMap;
@property (nonatomic, assign) OSSpinLock lock;
@end

@implementation JSONKeyMapper

-(instancetype)init
{
    self = [super init];
    if (self) {
        //initialization
        self.toModelMap = [NSMutableDictionary dictionary];
        self.toJSONMap  = [NSMutableDictionary dictionary];
    }
    return self;
}

-(instancetype)initWithJSONToModelBlock:(JSONModelKeyMapBlock)toModel
                       modelToJSONBlock:(JSONModelKeyMapBlock)toJSON
{
    self = [self init];
    
    if (self) {
        
        __weak JSONKeyMapper* weakSelf = self;
        
        _JSONToModelKeyBlock = [^NSString* (NSString* keyName) {
            
            __strong JSONKeyMapper* strongSelf = weakSelf;

            //try to return cached transformed key
            if (strongSelf.toModelMap[keyName]) {
                return strongSelf.toModelMap[keyName];
            }
            
            //try to convert the key, and store in the cache
            NSString* result = toModel(keyName);
            
            OSSpinLockLock(&strongSelf->_lock);
            strongSelf.toModelMap[keyName] = result;
            OSSpinLockUnlock(&strongSelf->_lock);
            
            return result;
            
        } copy];
        
        _modelToJSONKeyBlock = [^NSString* (NSString* keyName) {
            
            __strong JSONKeyMapper *strongSelf = weakSelf;
            
            //try to return cached transformed key
            if (strongSelf.toJSONMap[keyName]) {
                return strongSelf.toJSONMap[keyName];
            }
            
            //try to convert the key, and store in the cache
            NSString* result = toJSON(keyName);
            
            OSSpinLockLock(&strongSelf->_lock);
            strongSelf.toJSONMap[keyName] = result;
            OSSpinLockUnlock(&strongSelf->_lock);
            
            return result;
            
        } copy];
        
    }
    
    return self;
}

-(instancetype)initWithDictionary:(NSDictionary *)map
{
    self = [super init];
    if (self) {
        
        NSDictionary *userToModelMap = [map copy];
        NSDictionary *userToJSONMap  = [self swapKeysAndValuesInDictionary:map];
        
        _JSONToModelKeyBlock = ^NSString *(NSString *keyName) {
            NSString *result = [userToModelMap valueForKeyPath:keyName];
            return result ? result : keyName;
        };
        
        _modelToJSONKeyBlock = ^NSString *(NSString *keyName) {
            NSString *result = [userToJSONMap valueForKeyPath:keyName];
            return result ? result : keyName;
        };
    }
    
    return self;
}

- (NSDictionary *)swapKeysAndValuesInDictionary:(NSDictionary *)dictionary
{
    NSMutableDictionary *swapped = [NSMutableDictionary new];
    
    [dictionary enumerateKeysAndObjectsUsingBlock:^(NSString *key, NSString *value, BOOL *stop) {
        NSAssert([value isKindOfClass:[NSString class]], @"Expect keys and values to be NSString");
        NSAssert([key isKindOfClass:[NSString class]], @"Expect keys and values to be NSString");
        swapped[value] = key;
    }];
    
    return swapped;
}

-(NSString*)convertValue:(NSString*)value isImportingToModel:(BOOL)importing
{
    return !importing?_JSONToModelKeyBlock(value):_modelToJSONKeyBlock(value);
}

+(instancetype)mapperFromUnderscoreCaseToCamelCase
{
    JSONModelKeyMapBlock toModel = ^ NSString* (NSString* keyName) {

        //bail early if no transformation required
        if ([keyName rangeOfString:@"_"].location==NSNotFound) return keyName;

        //derive camel case out of underscore case
        NSString* camelCase = [keyName capitalizedString];
        camelCase = [camelCase stringByReplacingOccurrencesOfString:@"_" withString:@""];
        camelCase = [camelCase stringByReplacingCharactersInRange:NSMakeRange(0, 1) withString:[[camelCase substringToIndex:1] lowercaseString] ];
        
        return camelCase;
    };

    JSONModelKeyMapBlock toJSON = ^ NSString* (NSString* keyName) {
        
        NSMutableString* result = [NSMutableString stringWithString:keyName];
        NSRange upperCharRange = [result rangeOfCharacterFromSet:[NSCharacterSet uppercaseLetterCharacterSet]];

        //handle upper case chars
        while ( upperCharRange.location!=NSNotFound) {

            NSString* lowerChar = [[result substringWithRange:upperCharRange] lowercaseString];
            [result replaceCharactersInRange:upperCharRange
                                  withString:[NSString stringWithFormat:@"_%@", lowerChar]];
            upperCharRange = [result rangeOfCharacterFromSet:[NSCharacterSet uppercaseLetterCharacterSet]];
        }

        //handle numbers
        NSRange digitsRange = [result rangeOfCharacterFromSet:[NSCharacterSet decimalDigitCharacterSet]];
        while ( digitsRange.location!=NSNotFound) {
            
            NSRange digitsRangeEnd = [result rangeOfString:@"\\D" options:NSRegularExpressionSearch range:NSMakeRange(digitsRange.location, result.length-digitsRange.location)];
            if (digitsRangeEnd.location == NSNotFound) {
                //spands till the end of the key name
                digitsRangeEnd = NSMakeRange(result.length, 1);
            }
            
            NSRange replaceRange = NSMakeRange(digitsRange.location, digitsRangeEnd.location - digitsRange.location);
            NSString* digits = [result substringWithRange:replaceRange];
            
            [result replaceCharactersInRange:replaceRange withString:[NSString stringWithFormat:@"_%@", digits]];
            digitsRange = [result rangeOfCharacterFromSet:[NSCharacterSet decimalDigitCharacterSet] options:kNilOptions range:NSMakeRange(digitsRangeEnd.location+1, result.length-digitsRangeEnd.location-1)];
        }
        
        return result;
    };

    return [[self alloc] initWithJSONToModelBlock:toModel
                                 modelToJSONBlock:toJSON];
    
}

+(instancetype)mapperFromUpperCaseToLowerCase
{
    JSONModelKeyMapBlock toModel = ^ NSString* (NSString* keyName) {
        NSString*lowercaseString = [keyName lowercaseString];
        return lowercaseString;
    };

    JSONModelKeyMapBlock toJSON = ^ NSString* (NSString* keyName) {

        NSString *uppercaseString = [keyName uppercaseString];

        return uppercaseString;
    };

    return [[self alloc] initWithJSONToModelBlock:toModel
                                 modelToJSONBlock:toJSON];

}

+ (instancetype)mapper:(JSONKeyMapper *)baseKeyMapper withExceptions:(NSDictionary *)exceptions
{
    NSArray *keys = exceptions.allKeys;
    NSArray *values = [exceptions objectsForKeys:keys notFoundMarker:[NSNull null]];

    NSDictionary *toModelMap = [NSDictionary dictionaryWithObjects:values forKeys:keys];
    NSDictionary *toJsonMap = [NSDictionary dictionaryWithObjects:keys forKeys:values];

    JSONModelKeyMapBlock toModel = ^NSString *(NSString *keyName) {
        if (!keyName)
            return nil;

        if (toModelMap[keyName])
            return toModelMap[keyName];

        return baseKeyMapper.JSONToModelKeyBlock(keyName);
    };

    JSONModelKeyMapBlock toJson = ^NSString *(NSString *keyName) {
        if (!keyName)
            return nil;

        if (toJsonMap[keyName])
            return toJsonMap[keyName];

        return baseKeyMapper.modelToJSONKeyBlock(keyName);
    };

    return [[self alloc] initWithJSONToModelBlock:toModel modelToJSONBlock:toJson];
}

@end
