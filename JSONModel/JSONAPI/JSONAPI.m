//
//  JSONAPI.m
//  JSONModelDemo
//
//  Created by Marin Todorov on 05/12/2012.
//  Copyright (c) 2012 Underplot ltd. All rights reserved.
//

#import "JSONAPI.h"

static JSONAPI* sharedInstance = nil;

@interface JSONAPI ()
@property (strong, nonatomic) NSString* baseURLString;
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

@end
