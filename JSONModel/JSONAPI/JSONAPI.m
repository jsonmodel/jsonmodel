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
    NSMutableString* query = [NSMutableString stringWithString:@""];
    if (params) {
        [query appendFormat:@"?"];
        for (NSString* key in [params allKeys]) {
            [query appendFormat:@"%@=%@&", key, params[key]];
        }
    }
    
    NSString* fullURL = [NSString stringWithFormat:@"%@%@%@", sharedInstance.baseURLString, path, query];
    
    id json = [JSONHTTPClient getJSONFromURLWithString: fullURL];
    return json;
}

+(id)postWithPath:(NSString*)path andParams:(NSDictionary*)params
{
    NSAssert(NO, @"not implemnted");
    return nil;
}

-(NSString*)urlEncode:(NSString*)unescaped
{
    return (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(
                                                                                 NULL,
                                                                                 (__bridge CFStringRef) unescaped,
                                                                                 NULL,
                                                                                 (CFStringRef)@"!*'();:@&=+$,/?%#[]",
                                                                                 kCFStringEncodingUTF8));
}

@end
