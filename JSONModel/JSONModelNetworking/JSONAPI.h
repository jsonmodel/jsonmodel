//
//  JSONAPI.h
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
#import "JSONHTTPClient.h"

/////////////////////////////////////////////////////////////////////////////////////////////

/**
 * Class for working with JSON APIs. It builds upon the JSONHTTPClient class
 * and facilitates making requests to the same web host. Also features helper
 * method for making calls to a JSON RPC service
 */
@interface JSONAPI : NSObject

/////////////////////////////////////////////////////////////////////////////////////////////

/** @name Configuring the API */
/**
 * Sets the API url
 * @param base the API url as a string
 */
+(void)setAPIBaseURLWithString:(NSString*)base;

/**
 * Sets the default content type for the requests/responses
 * @param ctype The content-type as a string. Some possible types, 
 * depending on the service: application/json, text/json, x-application/javascript, etc.
 */
+(void)setContentType:(NSString*)ctype;

/////////////////////////////////////////////////////////////////////////////////////////////

/** @name Making GET API requests */
/**
 * Makes a synchronious GET request to the API
 * @param path the URL path to add to the base API URL for this HTTP call
 * @param params the variables to pass to the API
 * @param err pointer to an NSError object to pass back an error if needed
 * @return the JSON response as desrialized object
 */
+(id)getWithPath:(NSString*)path andParams:(NSDictionary*)params error:(NSError**)err;

/**
 * Makes an asynchronious GET request to the API
 * @param path the URL path to add to the base API URL for this HTTP call
 * @param params the variables to pass to the API
 * @param completeBlock a JSONObjectBlock block to execute upon completion
 * @return the JSON response as desrialized object
 */
+(void)getWithPath:(NSString*)path andParams:(NSDictionary*)params completion:(JSONObjectBlock)completeBlock;

/////////////////////////////////////////////////////////////////////////////////////////////

/** @name Making POST API requests */
/**
 * Makes a POST request to the API
 * @param path the URL path to add to the base API URL for this HTTP call
 * @param params the variables to pass to the API
 * @param err pointer to an NSError object to pass back an error if needed
 * @return the JSON response as desrialized object
 */
+(id)postWithPath:(NSString*)path andParams:(NSDictionary*)params error:(NSError**)err;

/**
 * Makes a POST request to the API
 * @param path the URL path to add to the base API URL for this HTTP call
 * @param params the variables to pass to the API
 * @param completeBlock a JSONObjectBlock block to execute upon completion
 * @return the JSON response as desrialized object
 */
+(void)postWithPath:(NSString*)path andParams:(NSDictionary*)params completion:(JSONObjectBlock)completeBlock;

/////////////////////////////////////////////////////////////////////////////////////////////

/** @name JSON RPC (1.0) request method */
/**
 * Makes a synchronious JSON RPC request to the API
 * @param method the HTTP method name; GET or POST only
 * @param args the list of arguments to pass to the API
 * @param err pointer to an NSError object to pass back an error if needed
 * @return the JSON response as desrialized object
 */
+(id)rpcWithMethodName:(NSString*)method andArguments:(NSArray*)args error:(NSError**)err;

/**
 * Makes an asynchronious JSON RPC request to the API
 * @param method the HTTP method name; GET or POST only
 * @param args the list of arguments to pass to the API
 * @param completeBlock JSONObjectBlock to execute upon completion
 * @return the JSON response as desrialized object
 */
+(void)rpcWithMethodName:(NSString*)method andArguments:(NSArray*)args completion:(JSONObjectBlock)completeBlock;

/////////////////////////////////////////////////////////////////////////////////////////////

@end
