//
//  JSONModelHTTPClient.m
//
//  @version 0.8.3
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

#import "JSONHTTPClient.h"

#pragma mark - constants
NSString * const kHTTPMethodGET = @"GET";
NSString * const kHTTPMethodPOST = @"POST";

#pragma mark - static variables

static long requestId = 0;

#ifdef __IPHONE_OS_VERSION_MAX_ALLOWED
static int defaultTextEncoding = NSUTF8StringEncoding;
static int defaultCachePolicy = NSURLRequestReloadIgnoringLocalCacheData;
#else
static long defaultTextEncoding = NSUTF8StringEncoding;
static long defaultCachePolicy = NSURLRequestReloadIgnoringLocalCacheData;
#endif

static BOOL doesControlIndicator = YES;

static NSMutableDictionary* requestHeaders = nil;
static NSMutableDictionary* flags = nil;

@interface JSONHTTPClient()

+(NSData*)syncRequestDataFromURL:(NSURL*)url method:(NSString*)method params:(NSDictionary*)params;
+(NSData*)syncRequestDataFromURL:(NSURL*)url method:(NSString*)method requestBody:(NSString*)bodyString;

+(void)setNetworkIndicatorVisible:(BOOL)isVisible;

@end

@implementation JSONHTTPClient

#pragma mark - initialization
+(void)initialize
{
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        requestHeaders = [NSMutableDictionary dictionary];
        flags = [NSMutableDictionary dictionaryWithCapacity:10];
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

+(void)setDefaultCachingPolicy:(NSURLRequestCachePolicy)policy
{
    defaultCachePolicy = policy;
}

+(void)setControlsNetworkIndicator:(BOOL)does
{
    doesControlIndicator = does;
}

#pragma mark - convenience methods for requests
+(id)getJSONFromURLWithString:(NSString*)urlString
{
    return [self JSONFromURLWithString:urlString method:kHTTPMethodGET params:nil orBodyString:nil];
}

+(id)getJSONFromURLWithString:(NSString*)urlString params:(NSDictionary*)params
{
    return [self JSONFromURLWithString:urlString method:kHTTPMethodGET params:params orBodyString:nil];
}

+(id)postJSONFromURLWithString:(NSString*)urlString params:(NSDictionary*)params
{
    return [self JSONFromURLWithString:urlString method:kHTTPMethodPOST params:params orBodyString:nil];
}

+(id)postJSONFromURLWithString:(NSString*)urlString bodyString:(NSString*)bodyString
{
    return [self JSONFromURLWithString:urlString method:kHTTPMethodPOST params:nil orBodyString:bodyString];
}

#pragma mark - base request methods
+(id)JSONFromURLWithString:(NSString*)urlString method:(NSString*)method params:(NSDictionary*)params orBodyString:(NSString*)bodyString
{    
    requestId++;
    
    NSString* semaphoreKey = [NSString stringWithFormat:@"rid: %ld", requestId];
    
    __block NSDictionary* json = nil;
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        NSData* responseData = nil;
        
        if (bodyString) {
            
            responseData = [self syncRequestDataFromURL: [NSURL URLWithString:urlString]
                                                 method: method
                                            requestBody: bodyString];
        } else {
            
            responseData = [self syncRequestDataFromURL: [NSURL URLWithString:urlString]
                                                 method: method
                                                 params: params];
        }
        
        //NSLog(@"server response: %@", [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding]);
        
        @try {
            NSAssert(responseData, nil);
            json = [NSJSONSerialization JSONObjectWithData:responseData options:kNilOptions error:nil];
            NSAssert(json, nil);
        }
        @catch (NSException* e) {
            //no need to do anything, will return nil by default
        }
        
        [self lift: semaphoreKey ];
        
    });
    
    [self waitForKey: semaphoreKey ];
    return json;
}

+(NSData*)syncRequestDataFromURL:(NSURL*)url method:(NSString*)method requestBody:(NSString*)bodyString
{
    if (doesControlIndicator) dispatch_async(dispatch_get_main_queue(), ^{[self setNetworkIndicatorVisible:YES];});

    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url
                                                                cachePolicy:defaultCachePolicy
                                                            timeoutInterval:60];
	[request setHTTPMethod:method];
    
    if (bodyString) {
        [request addValue:@"application/json; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
        //[request addValue:@"application/x-www-form-urlencoded" forHTTPHeaderField: @"Content-Type"];
        //[request addValue:@"8bit" forHTTPHeaderField:@"Content-Transfer-Encoding"];
    }
    
    for (NSString* key in [requestHeaders allKeys]) {
        [request addValue:requestHeaders[key] forHTTPHeaderField:key];
    }
    
    if (bodyString) {
        //BODY params
        NSData* bodyData = [bodyString dataUsingEncoding:defaultTextEncoding];
        [request setHTTPBody: bodyData];
#ifdef __IPHONE_OS_VERSION_MAX_ALLOWED
        [request addValue:[NSString stringWithFormat:@"%i", [bodyData length]] forHTTPHeaderField:@"Content-Length"];
#else
        [request addValue:[NSString stringWithFormat:@"%ld", [bodyData length]] forHTTPHeaderField:@"Content-Length"];
#endif
    }
    
    //prepare output
	NSHTTPURLResponse* response = nil;
	NSError* error = nil;
    
    //fire the request
	NSData *responseData = [NSURLConnection sendSynchronousRequest: request
                                                 returningResponse: &response
                                                             error: &error];
    
    if (doesControlIndicator) dispatch_async(dispatch_get_main_queue(), ^{[self setNetworkIndicatorVisible:NO];});
    
	if ([response statusCode] >= 200 && [response statusCode] < 300) {
        //OK HTTP responses
        return responseData;
        
	} else {
        
        //HTTP errors
        return nil;
    }
}

+(NSData*)syncRequestDataFromURL:(NSURL*)url method:(NSString*)method params:(NSDictionary*)params
{
    //create the request body
    NSMutableString* paramsString = nil;
    if (params) {
        paramsString = [NSMutableString stringWithString:@""];
        for (NSString* key in [params allKeys]) {
            [paramsString appendFormat:@"%@=%@&", key, [self urlEncode:params[key]] ];
        }
    }
    
    NSString* requestBodyString = nil;
    
    //set the request params
    if ([method isEqualToString:kHTTPMethodPOST]) {
        requestBodyString = paramsString;
    } else if (paramsString) {
        //URL params
        url = [NSURL URLWithString:[NSString stringWithFormat:
                                    @"%@?%@", [url absoluteString], paramsString
                                    ]];
    }
    
    return [self syncRequestDataFromURL:url method:method requestBody:requestBodyString];
}

#pragma mark - helper methods
+(NSString*)urlEncode:(NSString*)string
{
    return (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(
                                                                                 NULL,
                                                                                 (__bridge CFStringRef) string,
                                                                                 NULL,
                                                                                 (CFStringRef)@"!*'();:@&=+$,/?%#[]",
                                                                                 kCFStringEncodingUTF8));
}

#pragma mark - Semaphore methods
+(BOOL)isLifted:(NSString*)key
{
    return [flags objectForKey:key]!=nil;
}

+(void)lift:(NSString*)key
{
    [flags setObject:@"YES" forKey: key];
}

+(void)waitForKey:(NSString*)key
{
    BOOL keepRunning = YES;
    
    while (keepRunning && [[NSRunLoop currentRunLoop] runMode: NSDefaultRunLoopMode beforeDate:[NSDate dateWithTimeIntervalSinceNow:0.5]]) {
        keepRunning = ![self isLifted: key];
    }
    
    [flags removeObjectForKey:key];
}

#pragma mark - Async calls
+(void)JSONFromURLWithString:(NSString*)urlString method:(NSString*)method params:(NSDictionary*)params orBodyString:(NSString*)bodyString completion:(JSONObjectBlock)completeBlock
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        NSDictionary* jsonObject = nil;
        JSONModelError* error = nil;
        NSData* responseData = nil;
        
        @try {
            if (bodyString) {
                responseData = [self syncRequestDataFromURL: [NSURL URLWithString:urlString]
                                                     method: method
                                                requestBody: bodyString];
            } else {
                responseData = [self syncRequestDataFromURL: [NSURL URLWithString:urlString]
                                                     method: method
                                                     params: params];
            }

            jsonObject = [NSJSONSerialization JSONObjectWithData:responseData options:kNilOptions error:&error];
        }
        @catch (NSException *exception) {
            error = [JSONModelError errorBadResponse];
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (completeBlock) {
                completeBlock(jsonObject, error);
            }
        });
    });
}

+(void)getJSONFromURLWithString:(NSString*)urlString completion:(JSONObjectBlock)completeBlock
{
    [self JSONFromURLWithString:urlString method:kHTTPMethodGET
                         params:nil
                   orBodyString:nil completion:^(NSDictionary *json, JSONModelError* e) {
                       if (completeBlock) completeBlock(json, e);
                   }];
}

+(void)getJSONFromURLWithString:(NSString*)urlString params:(NSDictionary*)params completion:(JSONObjectBlock)completeBlock
{
    [self JSONFromURLWithString:urlString method:kHTTPMethodGET
                         params:params
                   orBodyString:nil completion:^(NSDictionary *json, JSONModelError* e) {
                       if (completeBlock) completeBlock(json, e);
                   }];
}

+(void)postJSONFromURLWithString:(NSString*)urlString params:(NSDictionary*)params completion:(JSONObjectBlock)completeBlock
{
    [self JSONFromURLWithString:urlString method:kHTTPMethodPOST
                         params:params
                   orBodyString:nil completion:^(NSDictionary *json, JSONModelError* e) {
                       if (completeBlock) completeBlock(json, e);
                   }];

}

+(void)postJSONFromURLWithString:(NSString*)urlString bodyString:(NSString*)bodyString completion:(JSONObjectBlock)completeBlock
{
    [self JSONFromURLWithString:urlString method:kHTTPMethodPOST
                         params:nil
                   orBodyString:bodyString completion:^(NSDictionary *json, JSONModelError* e) {
                       if (completeBlock) completeBlock(json, e);
                   }];
}

+(void)setNetworkIndicatorVisible:(BOOL)isVisible
{
#ifdef __IPHONE_OS_VERSION_MAX_ALLOWED
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:isVisible];
#endif
}

@end
