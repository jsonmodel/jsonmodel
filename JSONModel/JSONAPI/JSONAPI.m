//
//  JSONAPI.m
//  JSONModelDemo
//
//  Created by Marin Todorov on 05/12/2012.
//  Copyright (c) 2012 Underplot ltd. All rights reserved.
//

#import "JSONAPI.h"

static JSONAPI* sharedInstance = nil;
static long jsonRpcId = 0;

@interface JSONAPI ()
@property (strong, nonatomic) NSString* baseURLString;
@property (strong, nonatomic) NSString* ctype;
@end

@implementation JSONAPI

+(void)initialize
{
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        sharedInstance = [[JSONAPI alloc] init];
        sharedInstance.ctype = @"application/json";
    });
}

+(void)setAPIBaseURLWithString:(NSString*)base
{
    sharedInstance.baseURLString = base;
}

+(void)setContentType:(NSString*)ctype
{
    sharedInstance.ctype = ctype;
}

+(id)getWithPath:(NSString*)path andParams:(NSDictionary*)params
{
    NSString* fullURL = [NSString stringWithFormat:@"%@%@", sharedInstance.baseURLString, path];
    
    id json = [JSONHTTPClient getJSONFromURLWithString: fullURL params:params];
    return json;
}

+(id)postWithPath:(NSString*)path andParams:(NSDictionary*)params
{
    NSString* fullURL = [NSString stringWithFormat:@"%@%@", sharedInstance.baseURLString, path];
    
    id json = [JSONHTTPClient postJSONFromURLWithString: fullURL params:params];
    return json;
}

+(id)rpcWithMethodName:(NSString*)method andArguments:(NSArray*)args
{
    if (!args) args = @[];
    
    NSDictionary* jsonRequest = @{
        @"id": [NSNumber numberWithLong: ++jsonRpcId],
        @"params": args,
        @"method": method
    };
    
    NSData* jsonRequestData = [NSJSONSerialization dataWithJSONObject:jsonRequest
                                                              options:kNilOptions
                                                                error:nil];
    NSString* jsonRequestString = [[NSString alloc] initWithData:jsonRequestData encoding: NSUTF8StringEncoding];
    
    id json = [JSONHTTPClient postJSONFromURLWithString: sharedInstance.baseURLString
                                             bodyString: jsonRequestString];
    return json;
}

@end
