//
//  JSONModel.h
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

#import <Foundation/Foundation.h>
#import "JSONValueTransformer.h"

#pragma mark - Optional property protocol
@protocol Optional
@end

#pragma mark - Type not allowed exception
@interface JSONModelTypeNotAllowedException: NSException
@end

#pragma mark - Type not allowed exception
@interface JSONModelInvalidDataException: NSException
@end


#pragma mark - JSONModelClassProperty interface
@interface JSONModelClassProperty : NSObject
  @property (strong, nonatomic) NSString* name;
  @property (strong, nonatomic) NSString* type;
  @property (strong, nonatomic) NSString* protocol;
  @property (assign, nonatomic) BOOL isOptional;
@end

#pragma mark - JSONModel protocol
@protocol AbstractJSONModelProtocol <NSObject>

@required
  -(id)initWithDictionary:(NSDictionary*)d;
  -(NSDictionary*)toDictionary;
@end

#pragma mark - JSONModel interface
@interface JSONModel : NSObject <AbstractJSONModelProtocol>
  -(id)initWithString:(NSString*)s;
  -(id)initWithDictionary:(NSDictionary*)d;
  -(id)initWithString:(NSString *)s usingEncoding:(NSStringEncoding)encoding;

  -(NSDictionary*)toDictionary;
  -(NSString*)toJSON;

  +(NSMutableArray*)arrayOfObjectsFromDictionaries:(NSArray*)a;
  +(NSMutableArray*)arrayOfDictionariesFromObjects:(NSArray*)a;

@end