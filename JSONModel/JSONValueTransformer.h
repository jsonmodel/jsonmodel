//
//  JSONValueTransformer.h
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

#pragma mark - extern definitons
extern BOOL isNull(id value);

#pragma mark - JSONValueTransformer interface
@interface JSONValueTransformer : NSObject

+(Class)classByResolvingClusterClasses:(Class)sourceClass;

@property (strong, nonatomic, readonly) NSDictionary* primitivesNames;

#pragma mark - NSMutableString <-> NSString
-(NSMutableString*)NSMutableStringFromNSString:(NSString*)string;

#pragma mark - NSMutableArray <-> NSArray
-(NSMutableArray*)NSMutableArrayFromNSArray:(NSArray*)array;

#pragma mark - NSMutableDictionary <-> NSDictionary
-(NSMutableDictionary*)NSMutableDictionaryFromNSDictionary:(NSDictionary*)dict;

#pragma mark - NSSet <-> NSArray
-(NSSet*)NSSetFromNSArray:(NSArray*)array;
-(NSMutableSet*)NSMutableSetFromNSArray:(NSArray*)array;
-(NSArray*)JSONObjectFromNSSet:(NSSet*)set;
-(NSArray*)JSONObjectFromNSMutableSet:(NSMutableSet*)set;

#pragma mark - BOOL <-> number
-(NSNumber*)BOOLFromNSNumber:(NSNumber*)number;

#pragma mark - string <-> number
-(NSNumber*)NSNumberFromNSString:(NSString*)string;
-(NSString*)NSStringFromNSNumber:(NSNumber*)number;

#pragma mark - string <-> url
-(NSURL*)NSURLFromNSString:(NSString*)string;
-(NSString*)JSONObjectFromNSURL:(NSURL*)url;

#pragma mark - string <-> date
/*  string <-> date using the W3C format ISO8601 */
-(NSDate*)NSDateFromNSString:(NSString*)string;
-(NSString*)JSONObjectFromNSDate:(NSDate*)date;

@end