//
//  JSONKeyMapper.m
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

#import "JSONKeyMapper.h"

@interface JSONKeyMapper()
@property (nonatomic, strong) NSMutableDictionary *toModelMap;
@property (nonatomic, strong) NSMutableDictionary *toJSONMap;
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
        __weak JSONKeyMapper *myself = self;
        //the json to model convertion block
        _JSONToModelKeyBlock = ^NSString*(NSString* keyName) {

            //try to return cached transformed key
            if (myself.toModelMap[keyName]) return myself.toModelMap[keyName];
            
            //try to convert the key, and store in the cache
            NSString* result = toModel(keyName);
            myself.toModelMap[keyName] = result;
            return result;
        };
        
        _modelToJSONKeyBlock = ^NSString*(NSString* keyName) {
            
            //try to return cached transformed key
            if (myself.toJSONMap[keyName]) return myself.toJSONMap[keyName];
            
            //try to convert the key, and store in the cache
            NSString* result = toJSON(keyName);
            myself.toJSONMap[keyName] = result;
            return result;
            
        };
        
    }
    
    return self;
}

-(instancetype)initWithDictionary:(NSDictionary*)map
{
    self = [super init];
    if (self) {
        //initialize

        NSMutableDictionary* userToModelMap = [NSMutableDictionary dictionaryWithDictionary: map];
        NSMutableDictionary* userToJSONMap  = [NSMutableDictionary dictionaryWithObjects:map.allKeys forKeys:map.allValues];
        
        _JSONToModelKeyBlock = ^NSString*(NSString* keyName) {
            NSString* result = [userToModelMap valueForKeyPath: keyName];
            return result?result:keyName;
        };
        
        _modelToJSONKeyBlock = ^NSString*(NSString* keyName) {
            NSString* result = [userToJSONMap valueForKeyPath: keyName];
            return result?result:keyName;
        };
        
    }
    
    return self;
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
        
        NSMutableString* result = [keyName mutableCopy];
        
        NSRegularExpression* regex = [NSRegularExpression regularExpressionWithPattern:@"([A-Z][a-z]*)|(\\d+)" options:kNilOptions error:NULL];
        NSInteger offset = 0;
        for (NSTextCheckingResult* item in [regex matchesInString:result options:0 range:NSMakeRange(0, [result length])]) {
          NSRange resultRange = [item rangeAtIndex:0];
          resultRange.location += offset;
          NSString* matchString = [result substringWithRange:resultRange];
          NSString *replacement = [@"_" stringByAppendingString:[matchString lowercaseString]];
          [result replaceCharactersInRange:resultRange withString:replacement];
          
          offset += ([replacement length] - [matchString length]);
        }
      
        return [result copy];
    };

    return [[self alloc] initWithJSONToModelBlock:toModel
                                 modelToJSONBlock:toJSON];
    
}

@end
