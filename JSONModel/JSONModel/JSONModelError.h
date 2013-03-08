//
//  JSONModelError.h
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

#import <Foundation/Foundation.h>

/////////////////////////////////////////////////////////////////////////////////////////////
enum kJSONModelErrorTypes
{
    kJSONModelErrorInvalidData = 1,
    kJSONModelErrorBadResponse = 2,
    kJSONModelErrorBadJSON = 3,
    kJSONModelErrorModelIsInvalid = 4,
    kJSONModelErrorNilInput = 5
};

/////////////////////////////////////////////////////////////////////////////////////////////
/** The domain name used for the JSONModelError instances */
extern NSString* const JSONModelErrorDomain;

/** 
 * If the model JSON input misses keys that are required, check the
 * userInfo dictionary of the JSONModelError instance you get back - 
 * under the kJSONModelErrorInvalidData key you will find a list of the 
 * names of the missing keys.
 */
extern NSString* const kJSONModelMissingKeys;

/////////////////////////////////////////////////////////////////////////////////////////////
/**
 * Custom NSError subclass with shortcut methods for creating 
 * the common JSONModel errors
 */
@interface JSONModelError : NSError

/**
 * Creates a JSONModelError instance with code kJSONModelErrorInvalidData = 1
 */
+(id)errorInvalidData;

/**
 * Creates a JSONModelError instance with code kJSONModelErrorInvalidData = 1
 * @param keys a set of field names that were required, but not found in the input
 */
+(id)errorInvalidDataWithMissingKeys:(NSSet*)keys;

/**
 * Creates a JSONModelError instance with code kJSONModelErrorBadResponse = 2
 */
+(id)errorBadResponse;

/**
 * Creates a JSONModelError instance with code kJSONModelErrorBadJSON = 3
 */
+(id)errorBadJSON;

/**
 * Creates a JSONModelError instance with code kJSONModelErrorModelIsInvalid = 4
 */
+(id)errorModelIsInvalid;

/**
 * Creates a JSONModelError instance with code kJSONModelErrorNilInput = 5
 */
+(id)errorInputIsNil;

/////////////////////////////////////////////////////////////////////////////////////////////
@end