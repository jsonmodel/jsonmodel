//
//  JSONModelHTTPClient.m
//  JSONModelDemo
//
//  Created by Marin Todorov on 04/12/2012.
//  Copyright (c) 2012 Underplot ltd. All rights reserved.
//

#import "JSONHTTPClient.h"
#import "JSONModelSemaphore.h"

static long requestId = 0;

static int defaultTextEncoding = NSUTF8StringEncoding;
static int defaultCachePolicy = NSURLRequestReloadIgnoringLocalCacheData;

static NSMutableDictionary* requestHeaders = nil;

@implementation JSONHTTPClient

+(void)initialize
{
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        requestHeaders = [NSMutableDictionary dictionary];
    });
}

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
        
        [JSONModelSemaphore lift: semaphoreKey ];
        
    });
    
    [JSONModelSemaphore waitForKey: semaphoreKey ];
    return json;
}

+(NSData*)syncRequestDataFromURL:(NSURL*)url method:(NSString*)method requestBody:(NSString*)bodyString
{
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url
                                                                cachePolicy:defaultCachePolicy
                                                            timeoutInterval:60];
	[request setHTTPMethod:method];
    
	[request addValue:@"application/x-www-form-urlencoded" forHTTPHeaderField: @"Content-Type"];
    [request addValue:@"8bit" forHTTPHeaderField:@"Content-Transfer-Encoding"];
    
    for (NSString* key in [requestHeaders allKeys]) {
        [request addValue:requestHeaders[key] forHTTPHeaderField:key];
    }
    
    if (bodyString) {
        //BODY params
        NSData* bodyData = [bodyString dataUsingEncoding:defaultTextEncoding];
        [request setHTTPBody: bodyData];
        [request addValue:[NSString stringWithFormat:@"%i", [bodyData length]] forHTTPHeaderField:@"Content-Length"];
    }
    
    //prepare output
	NSHTTPURLResponse* response = nil;
	NSError* error = nil;
    
    //fire the request
	NSData *responseData = [NSURLConnection sendSynchronousRequest: request
                                                 returningResponse: &response
                                                             error: &error];
    
	if ([response statusCode] >= 200 && [response statusCode] < 300) {
        //OK - codes 2xx
        //NSString *result = [[NSString alloc] initWithData:responseData encoding: defaultTextEncoding];
        
        return responseData;
	} else {
        
        //HTTP errors
        return nil;
    }
}

+(NSData*)syncRequestDataFromURL:(NSURL*)url method:(NSString*)method params:(NSDictionary*)params
{
    //create the request body
    NSMutableString* paramsString = [NSMutableString stringWithString:@""];
    if (params) {
        for (NSString* key in [params allKeys]) {
            [paramsString appendFormat:@"%@=%@&", key, [self urlEncode:params[key]] ];
        }
    }
    
    NSString* requestBodyString = nil;
    
    //set the request params
    if ([method isEqualToString:kHTTPMethodPOST]) {
        requestBodyString = paramsString;
    } else {
        //URL params
        url = [NSURL URLWithString:[NSString stringWithFormat:
                                    @"%@?%@", [url absoluteString], paramsString
                                    ]];
    }
    
    return [self syncRequestDataFromURL:url method:method requestBody:requestBodyString];
}

+(NSString*)urlEncode:(NSString*)string
{
    return (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(
                                                                                 NULL,
                                                                                 (__bridge CFStringRef) string,
                                                                                 NULL,
                                                                                 (CFStringRef)@"!*'();:@&=+$,/?%#[]",
                                                                                 kCFStringEncodingUTF8));
}

@end
