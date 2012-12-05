//
//  JSONAPI.m
//  JSONModelDemo
//
//  Created by Marin Todorov on 05/12/2012.
//  Copyright (c) 2012 Underplot ltd. All rights reserved.
//

#import "JSONAPI.h"
#import "JSONHTTPClient.h"

static JSONAPI* sharedInstance = nil;

@interface JSONAPI ()
@property (strong, nonatomic) NSURL* baseURL;
@property (strong, nonatomic) NSString* ctype;
@end

@implementation JSONAPI

+(void)initialize
{
    sharedInstance = [[JSONAPI alloc] init];
    sharedInstance.ctype = @"application/json";
    
}

+(void)setAPIBaseURLWithString:(NSString*)base
{
    sharedInstance.baseURL = [NSURL URLWithString:base];
}

+(void)setContentType:(NSString*)ctype
{
    sharedInstance.ctype = ctype;
}

+(id)getWithPath:(NSString*)path andParams:(NSDictionary*)params
{
    NSURL* getURL = [NSURL URLWithString:path relativeToURL:sharedInstance.baseURL];
    
    if (params) {
        
    }
    
    id json = [JSONHTTPClient getJSONFromURL: getURL];
    return json;
}

+(id)postWithPath:(NSString*)path andParams:(NSDictionary*)params
{
    NSAssert(NO, @"not implemnted");
    return nil;
}


@end
