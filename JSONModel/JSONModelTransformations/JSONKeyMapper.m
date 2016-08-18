//
//  JSONKeyMapper.m
//
//  @version 1.4
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
@property (nonatomic, strong) NSMutableDictionary *toJSONMap;
@property (nonatomic, assign) OSSpinLock lock;
@end

@implementation JSONKeyMapper

-(instancetype)init
{
    self = [super init];
    if (self) {
        //initialization
        self.toJSONMap  = [NSMutableDictionary dictionary];
    }
    return self;
}

-(instancetype)initWithJSONToModelBlock:(JSONModelKeyMapBlock)toModel
                       modelToJSONBlock:(JSONModelKeyMapBlock)toJSON
{
    return [self initWithModelToJSONBlock:toJSON];
}

-(instancetype)initWithModelToJSONBlock:(JSONModelKeyMapBlock)toJSON
{
    self = [self init];

    if (self) {

        __weak JSONKeyMapper* weakSelf = self;

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

- (instancetype)initWithDictionary:(NSDictionary *)map
{
    NSDictionary *toJSON  = [JSONKeyMapper swapKeysAndValuesInDictionary:map];

    return [self initWithModelToJSONDictionary:toJSON];
}

- (instancetype)initWithModelToJSONDictionary:(NSDictionary *)toJSON
{
    if (!(self = [super init]))
        return nil;

    _modelToJSONKeyBlock = ^NSString *(NSString *keyName)
    {
        return [toJSON valueForKeyPath:keyName] ?: keyName;
    };

    return self;
}

+ (NSDictionary *)swapKeysAndValuesInDictionary:(NSDictionary *)dictionary
{
    NSArray *keys = dictionary.allKeys;
    NSArray *values = [dictionary objectsForKeys:keys notFoundMarker:[NSNull null]];

    return [NSDictionary dictionaryWithObjects:keys forKeys:values];
}

-(NSString*)convertValue:(NSString*)value isImportingToModel:(BOOL)importing
{
    return [self convertValue:value];
}

-(NSString*)convertValue:(NSString*)value
{
    return _modelToJSONKeyBlock(value);
}

+(instancetype)mapperFromUnderscoreCaseToCamelCase
{
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

    return [[self alloc] initWithModelToJSONBlock:toJSON];

}

+(instancetype)mapperFromUpperCaseToLowerCase
{
    JSONModelKeyMapBlock toJSON = ^ NSString* (NSString* keyName) {

        NSString *uppercaseString = [keyName uppercaseString];

        return uppercaseString;
    };

    return [[self alloc] initWithModelToJSONBlock:toJSON];

}

+ (instancetype)mapper:(JSONKeyMapper *)baseKeyMapper withExceptions:(NSDictionary *)exceptions
{
    NSDictionary *toJSON  = [JSONKeyMapper swapKeysAndValuesInDictionary:exceptions];

    return [self baseMapper:baseKeyMapper withModelToJSONExceptions:toJSON];
}

+ (instancetype)baseMapper:(JSONKeyMapper *)baseKeyMapper withModelToJSONExceptions:(NSDictionary *)toJSON
{
    return [[self alloc] initWithModelToJSONBlock:^NSString *(NSString *keyName)
    {
        if (!keyName)
            return nil;

        if (toJSON[keyName])
            return toJSON[keyName];

        return baseKeyMapper.modelToJSONKeyBlock(keyName);
    }];
}

@end
