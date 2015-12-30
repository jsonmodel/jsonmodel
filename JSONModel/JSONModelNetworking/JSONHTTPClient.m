//
//  JSONModelHTTPClient.m
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


#import "JSONHTTPClient.h"

typedef void (^RequestResultBlock)(NSData *data, JSONModelError *error);

#pragma mark - constants
NSString* const kHTTPMethodGET = @"GET";
NSString* const kHTTPMethodPOST = @"POST";

NSString* const kContentTypeAutomatic    = @"jsonmodel/automatic";
NSString* const kContentTypeJSON         = @"application/json";
NSString* const kContentTypeWWWEncoded   = @"application/x-www-form-urlencoded";

#pragma mark - static variables

/**
 * Defaults for HTTP requests
 */
static NSStringEncoding defaultTextEncoding = NSUTF8StringEncoding;
static NSURLRequestCachePolicy defaultCachePolicy = NSURLRequestReloadIgnoringLocalCacheData;

static int defaultTimeoutInSeconds = 60;

/**
 * Custom HTTP headers to send over with *each* request
 */
static NSMutableDictionary* requestHeaders = nil;

/**
 * Default request content type
 */
static NSString* requestContentType = nil;

#pragma mark - implementation
@implementation JSONHTTPClient

#pragma mark - initialization
+(void)initialize
{
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        requestHeaders = [NSMutableDictionary dictionary];
        requestContentType = kContentTypeAutomatic;
    });
}

#pragma mark - configuration methods
+(NSMutableDictionary*)requestHeaders
{
    return requestHeaders;
}

+(void)setDefaultTextEncoding:(NSStringEncoding)encoding
{
    defaultTextEncoding = encoding;
}

+(void)setCachingPolicy:(NSURLRequestCachePolicy)policy
{
    defaultCachePolicy = policy;
}

+(void)setTimeoutInSeconds:(int)seconds
{
    defaultTimeoutInSeconds = seconds;
}

+(void)setRequestContentType:(NSString*)contentTypeString
{
    requestContentType = contentTypeString;
}

#pragma mark - helper methods
+(NSString*)contentTypeForRequestString:(NSString*)requestString
{
    //fetch the charset name from the default string encoding
    NSString* contentType = requestContentType;

    if (requestString.length>0 && [contentType isEqualToString:kContentTypeAutomatic]) {
        //check for "eventual" JSON array or dictionary
        NSString* firstAndLastChar = [NSString stringWithFormat:@"%@%@",
                                      [requestString substringToIndex:1],
                                      [requestString substringFromIndex: requestString.length -1]
                                      ];
        
        if ([firstAndLastChar isEqualToString:@"{}"] || [firstAndLastChar isEqualToString:@"[]"]) {
            //guessing for a JSON request
            contentType = kContentTypeJSON;
        } else {
            //fallback to www form encoded params
            contentType = kContentTypeWWWEncoded;
        }
    }

    //type is set, just add charset
    NSString *charset = (NSString *)CFStringConvertEncodingToIANACharSetName(CFStringConvertNSStringEncodingToEncoding(NSUTF8StringEncoding));
    return [NSString stringWithFormat:@"%@; charset=%@", contentType, charset];
}

+(NSString*)urlEncode:(id<NSObject>)value
{
    //make sure param is a string
    if ([value isKindOfClass:[NSNumber class]]) {
        value = [(NSNumber*)value stringValue];
    }
    
    NSAssert([value isKindOfClass:[NSString class]], @"request parameters can be only of NSString or NSNumber classes. '%@' is of class %@.", value, [value class]);

    NSString *str = (NSString *)value;

#if __IPHONE_OS_VERSION_MIN_REQUIRED >= __IPHONE_7_0 || __MAC_OS_X_VERSION_MIN_REQUIRED >= __MAC_10_9
    return [str stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];

#else
    return (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(
                                                                                 NULL,
                                                                                 (__bridge CFStringRef)str,
                                                                                 NULL,
                                                                                 (CFStringRef)@"!*'();:@&=+$,/?%#[]",
                                                                                 kCFStringEncodingUTF8));
#endif
}

#pragma mark - networking worker methods
+(void)requestDataFromURL:(NSURL*)url method:(NSString*)method requestBody:(NSData*)bodyData headers:(NSDictionary*)headers handler:(RequestResultBlock)handler
{
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL: url
                                                                cachePolicy: defaultCachePolicy
                                                            timeoutInterval: defaultTimeoutInSeconds];
	[request setHTTPMethod:method];

    if ([requestContentType isEqualToString:kContentTypeAutomatic]) {
        //automatic content type
        if (bodyData) {
            NSString *bodyString = [[NSString alloc] initWithData:bodyData encoding:NSUTF8StringEncoding];
            [request setValue: [self contentTypeForRequestString: bodyString] forHTTPHeaderField:@"Content-type"];
        }
    } else {
        //user set content type
        [request setValue: requestContentType forHTTPHeaderField:@"Content-type"];
    }
    
    //add all the custom headers defined
    for (NSString* key in [requestHeaders allKeys]) {
        [request setValue:requestHeaders[key] forHTTPHeaderField:key];
    }
    
    //add the custom headers
    for (NSString* key in [headers allKeys]) {
        [request setValue:headers[key] forHTTPHeaderField:key];
    }
    
    if (bodyData) {
        [request setHTTPBody: bodyData];
        [request setValue:[NSString stringWithFormat:@"%lu", (unsigned long)bodyData.length] forHTTPHeaderField:@"Content-Length"];
    }

    void (^completionHandler)(NSData *, NSURLResponse *, NSError *) = ^(NSData *data, NSURLResponse *origResponse, NSError *origError) {
        NSHTTPURLResponse *response = (NSHTTPURLResponse *)origResponse;
        JSONModelError *error = nil;

        //convert an NSError to a JSONModelError
        if (origError) {
            error = [JSONModelError errorWithDomain:origError.domain code:origError.code userInfo:origError.userInfo];
        }

        //special case for http error code 401
        if (error.code == NSURLErrorUserCancelledAuthentication) {
            response = [[NSHTTPURLResponse alloc] initWithURL:url statusCode:401 HTTPVersion:@"HTTP/1.1" headerFields:@{}];
        }

        //if not OK status set the err to a JSONModelError instance
        if (!error && (response.statusCode >= 300 || response.statusCode < 200)) {
            error = [JSONModelError errorBadResponse];
        }

        //if there was an error, assign the response to the JSONModel instance
        if (error) {
            error.httpResponse = [response copy];
        }

        //empty respone, return nil instead
        if (!data.length) {
            data = nil;
        }
        
        handler(data, error);
    };

    //fire the request

#if __IPHONE_OS_VERSION_MIN_REQUIRED >= __IPHONE_7_0 || __MAC_OS_X_VERSION_MIN_REQUIRED >= __MAC_10_10
    NSURLSessionTask *task = [[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:completionHandler];
    [task resume];
#else
    NSOperationQueue *queue = [NSOperationQueue new];

    [NSURLConnection sendAsynchronousRequest:request queue:queue completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
        completionHandler(data, response, error);
    }];
#endif
}

+(void)requestDataFromURL:(NSURL*)url method:(NSString*)method params:(NSDictionary*)params headers:(NSDictionary*)headers handler:(RequestResultBlock)handler
{
    //create the request body
    NSMutableString* paramsString = nil;

    if (params) {
        //build a simple url encoded param string
        paramsString = [NSMutableString stringWithString:@""];
        for (NSString* key in [[params allKeys] sortedArrayUsingSelector:@selector(compare:)]) {
            [paramsString appendFormat:@"%@=%@&", key, [self urlEncode:params[key]] ];
        }
        if ([paramsString hasSuffix:@"&"]) {
            paramsString = [[NSMutableString alloc] initWithString: [paramsString substringToIndex: paramsString.length-1]];
        }
    }
    
    //set the request params
    if ([method isEqualToString:kHTTPMethodGET] && params) {

        //add GET params to the query string
        url = [NSURL URLWithString:[NSString stringWithFormat: @"%@%@%@",
                                    [url absoluteString],
                                    [url query] ? @"&" : @"?",
                                    paramsString
                                    ]];
    }
    
    //call the more general synq request method
    [self requestDataFromURL: url
                      method: method
                 requestBody: [method isEqualToString:kHTTPMethodPOST]?[paramsString dataUsingEncoding:NSUTF8StringEncoding]:nil
                     headers: headers
                       handler:handler];
}

#pragma mark - Async network request
+(void)JSONFromURLWithString:(NSString*)urlString method:(NSString*)method params:(NSDictionary*)params orBodyString:(NSString*)bodyString completion:(JSONObjectBlock)completeBlock
{
    [self JSONFromURLWithString:urlString
                         method:method
                         params:params
                   orBodyString:bodyString
                        headers:nil
                     completion:completeBlock];
}

+(void)JSONFromURLWithString:(NSString *)urlString method:(NSString *)method params:(NSDictionary *)params orBodyString:(NSString *)bodyString headers:(NSDictionary *)headers completion:(JSONObjectBlock)completeBlock
{
    [self JSONFromURLWithString:urlString
                         method:method
                         params:params
                     orBodyData:[bodyString dataUsingEncoding:NSUTF8StringEncoding]
                        headers:headers
                     completion:completeBlock];
}

+(void)JSONFromURLWithString:(NSString*)urlString method:(NSString*)method params:(NSDictionary *)params orBodyData:(NSData*)bodyData headers:(NSDictionary*)headers completion:(JSONObjectBlock)completeBlock
{
    RequestResultBlock handler = ^(NSData *responseData, JSONModelError *error) {
        id jsonObject = nil;

        //step 3: if there's no response so far, return a basic error
        if (!responseData && !error) {
            //check for false response, but no network error
            error = [JSONModelError errorBadResponse];
        }

        //step 4: if there's a response at this and no errors, convert to object
        if (error==nil) {
			// Note: it is possible to have a valid response with empty response data (204 No Content).
			// So only create the JSON object if there is some response data.
			if(responseData.length > 0)
			{
				//convert to an object
				jsonObject = [NSJSONSerialization JSONObjectWithData:responseData options:kNilOptions error:&error];
			}
        }
        //step 4.5: cover an edge case in which meaningful content is return along an error HTTP status code
        else if (error && responseData && jsonObject==nil) {
            //try to get the JSON object, while preserving the original error object
            jsonObject = [NSJSONSerialization JSONObjectWithData:responseData options:kNilOptions error:nil];
            //keep responseData just in case it contains error information
            error.responseData = responseData;
        }
        
        //step 5: invoke the complete block
        dispatch_async(dispatch_get_main_queue(), ^{
            if (completeBlock) {
                completeBlock(jsonObject, error);
            }
        });
    };

    NSURL *url = [NSURL URLWithString:urlString];

    if (bodyData) {
        [self requestDataFromURL:url method:method requestBody:bodyData headers:headers handler:handler];
    } else {
        [self requestDataFromURL:url method:method params:params headers:headers handler:handler];
    }
}

#pragma mark - request aliases
+(void)getJSONFromURLWithString:(NSString*)urlString completion:(JSONObjectBlock)completeBlock
{
    [self JSONFromURLWithString:urlString method:kHTTPMethodGET
                         params:nil
                   orBodyString:nil completion:^(id json, JSONModelError* e) {
                       if (completeBlock) completeBlock(json, e);
                   }];
}

+(void)getJSONFromURLWithString:(NSString*)urlString params:(NSDictionary*)params completion:(JSONObjectBlock)completeBlock
{
    [self JSONFromURLWithString:urlString method:kHTTPMethodGET
                         params:params
                   orBodyString:nil completion:^(id json, JSONModelError* e) {
                       if (completeBlock) completeBlock(json, e);
                   }];
}

+(void)postJSONFromURLWithString:(NSString*)urlString params:(NSDictionary*)params completion:(JSONObjectBlock)completeBlock
{
    [self JSONFromURLWithString:urlString method:kHTTPMethodPOST
                         params:params
                   orBodyString:nil completion:^(id json, JSONModelError* e) {
                       if (completeBlock) completeBlock(json, e);
                   }];

}

+(void)postJSONFromURLWithString:(NSString*)urlString bodyString:(NSString*)bodyString completion:(JSONObjectBlock)completeBlock
{
    [self JSONFromURLWithString:urlString method:kHTTPMethodPOST
                         params:nil
                   orBodyString:bodyString completion:^(id json, JSONModelError* e) {
                       if (completeBlock) completeBlock(json, e);
                   }];
}

+(void)postJSONFromURLWithString:(NSString*)urlString bodyData:(NSData*)bodyData completion:(JSONObjectBlock)completeBlock
{
    [self JSONFromURLWithString:urlString method:kHTTPMethodPOST
                         params:nil
                   orBodyString:[[NSString alloc] initWithData:bodyData encoding:defaultTextEncoding]
                                 completion:^(id json, JSONModelError* e) {
                       if (completeBlock) completeBlock(json, e);
                   }];
}

@end
