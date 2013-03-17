//
//  JSONModelHTTPClient.h
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

#import "JSONModel.h"

#pragma mark - definitions

/**
 * HTTP Request methods
 */
extern NSString* const kHTTPMethodGET;
extern NSString* const kHTTPMethodPOST;

/**
 * Content-type strings
 */
extern NSString* const kContentTypeAutomatic;
extern NSString* const kContentTypeJSON;
extern NSString* const kContentTypeWWWEncoded;

/**
 * A block type to handle incoming JSONModel instance and an error. 
 * You pass it to methods which create a model asynchroniously. When the operation is finished
 * you receive back the initialized model (or nil) and an error (or nil)
 *
 * @param model the newly created JSONModel instance or nil
 * @param e JSONModelError or nil
 */
typedef void (^JSONModelBlock)(JSONModel* model, JSONModelError* err);

typedef void (^JSONObjectBlock)(NSDictionary* json, JSONModelError* err);

/////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - configuration methods

/**
 * A very thin HTTP client that can do GET and POST HTTP requests.
 * It fetches only JSON data and also deserializes it using NSJSONSerialization.
 * 
 */
@interface JSONHTTPClient : NSObject

/////////////////////////////////////////////////////////////////////////////////////////////


/** @name HTTP Client configuration */
/**
 * A dictioanry of HTTP headers the client sends along the requests
 */
+(NSMutableDictionary*)requestHeaders;

/**
 * Sets the default encoding of the request body.
 * See NSStringEncoding for a list of supported encodings
 * @param encoding text encoding constant
 */
+(void)setDefaultTextEncoding:(NSStringEncoding)encoding;

/**
 * Sets the policies for caching HTTP data
 * See NSURLRequestCachePolicy for a list of the pre-defined policies
 * @param policy the caching policy
 */
+(void)setCachingPolicy:(NSURLRequestCachePolicy)policy;

/**
 * Sets the timeout for network calls
 * @param seconds the amount of seconds to wait before considering the call failed
 */
+(void)setTimeoutInSeconds:(int)seconds;

/**
 * A method to enable/disable automatic network indicator showing. 
 * Set to YES by default.
 * @param doesControlIndicator if YES, the library shows and hides the
 * system network indicator automatically on begin and end of 
 * network operations
 */
+(void)setControlsNetworkIndicator:(BOOL)doesControlIndicator;

/**
 * A method to set the default conent type of the request body
 * By default the content type is set to kContentTypeAutomatic
 * which checks the body request and decides between "application/json"
 * and "application/x-www-form-urlencoded"
 */
+(void)setRequestContentType:(NSString*)contentTypeString;

/////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - GET synchronious JSON calls

/** @name Making synchronious HTTP requests */
/**
 * Makes GET request to the given URL address and fetches a JSON response.
 * @param urlString the URL as a string
 * @param err a pointer to an NSError object, to pass back an error if needed
 * @return JSON compliant object or nil
 */
+(id)getJSONFromURLWithString:(NSString*)urlString error:(NSError**)err;

/**
 * Makes GET request to the given URL address and fetches a JSON response. Sends the params as a query string variables.
 * @param urlString the URL as a string
 * @param params a dictionary of key / value pairs to be send as variables to the request
 * @param err a pointer to an NSError object, to pass back an error if needed
 * @return JSON compliant object or nil
 */
+(id)getJSONFromURLWithString:(NSString*)urlString params:(NSDictionary*)params error:(NSError**)err;

/////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - POST synchronious JSON calls

/**
 * Makes POST request to the given URL address and fetches a JSON response. Sends the params as url encoded variables via the POST body.
 * @param urlString the URL as a string
 * @param params a dictionary of key / value pairs to be send as variables to the request
 * @param err a pointer to an NSError object, to pass back an error if needed
 * @return JSON compliant object or nil
 */
+(id)postJSONFromURLWithString:(NSString*)urlString params:(NSDictionary*)params error:(NSError**)err;

/**
 * Makes POST request to the given URL address and fetches a JSON response. Sends the bodyString param as the POST request body.
 * @param urlString the URL as a string
 * @param bodyString the body of the POST request as a string
 * @param err a pointer to an NSError object, to pass back an error if needed
 * @return JSON compliant object or nil
 */
+(id)postJSONFromURLWithString:(NSString*)urlString bodyString:(NSString*)bodyString error:(NSError**)err;

/**
 * Makes POST request to the given URL address and fetches a JSON response. Sends the bodyString param as the POST request body.
 * @param urlString the URL as a string
 * @param bodyData the body of the POST request as an NSData object
 * @param err a pointer to an NSError object, to pass back an error if needed
 * @return JSON compliant object or nil
 */
+(id)postJSONFromURLWithString:(NSString*)urlString bodyData:(NSData*)bodyData error:(NSError**)err;

/////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - GET asynchronious JSON calls

/** @name Making asynchronious HTTP requests */
/**
 * Makes GET request to the given URL address and fetches a JSON response.
 * @param urlString the URL as a string
 * @param completeBlock JSONObjectBlock to execute upon completion
 * @return JSON compliant object or nil
 */
+(void)getJSONFromURLWithString:(NSString*)urlString completion:(JSONObjectBlock)completeBlock;

/**
 * Makes GET request to the given URL address and fetches a JSON response. Sends the params as a query string variables.
 * @param urlString the URL as a string
 * @param params a dictionary of key / value pairs to be send as variables to the request
 * @param completeBlock JSONObjectBlock to execute upon completion
 * @return JSON compliant object or nil
 */
+(void)getJSONFromURLWithString:(NSString*)urlString params:(NSDictionary*)params completion:(JSONObjectBlock)completeBlock;

/////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - POST synchronious JSON calls

/**
 * Makes POST request to the given URL address and fetches a JSON response. Sends the bodyString param as the POST request body.
 * @param urlString the URL as a string
 * @param params a dictionary of key / value pairs to be send as variables to the request
 * @param completeBlock JSONObjectBlock to execute upon completion
 * @return JSON compliant object or nil
 */
+(void)postJSONFromURLWithString:(NSString*)urlString params:(NSDictionary*)params completion:(JSONObjectBlock)completeBlock;

/**
 * Makes POST request to the given URL address and fetches a JSON response. Sends the bodyString param as the POST request body.
 * @param urlString the URL as a string
 * @param bodyString the body of the POST request as a string
 * @param completeBlock JSONObjectBlock to execute upon completion
 * @return JSON compliant object or nil
 */
+(void)postJSONFromURLWithString:(NSString*)urlString bodyString:(NSString*)bodyString completion:(JSONObjectBlock)completeBlock;

/**
 * Makes POST request to the given URL address and fetches a JSON response. Sends the bodyString param as the POST request body.
 * @param urlString the URL as a string
 * @param bodyData the body of the POST request as an NSData object
 * @param completeBlock JSONObjectBlock to execute upon completion
 * @return JSON compliant object or nil
 */
+(void)postJSONFromURLWithString:(NSString*)urlString bodyData:(NSData*)bodyData completion:(JSONObjectBlock)completeBlock;


@end
