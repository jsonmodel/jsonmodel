//
//  JSONModelHTTPClient.h
//  JSONModelDemo
//
//  Created by Marin Todorov on 04/12/2012.
//  Copyright (c) 2012 Underplot ltd. All rights reserved.
//

#import "JSONModel.h"

#define kHTTPMethodGET @"GET"
#define kHTTPMethodPOST @"POST"

@interface JSONHTTPClient : JSONModel

+(NSMutableDictionary*)requestHeaders;
+(void)setDefaultTextEncoding:(NSStringEncoding)encoding;
+(void)setDefaultCachingPolicy:(NSURLRequestCachePolicy)policy;

+(id)getJSONFromURLWithString:(NSString*)urlString;
+(id)getJSONFromURLWithString:(NSString*)urlString params:(NSDictionary*)params;
+(id)postJSONFromURLWithString:(NSString*)urlString params:(NSDictionary*)params;
+(id)postJSONFromURLWithString:(NSString*)urlString bodyString:(NSString*)bodyString;

+(NSData*)syncRequestDataFromURL:(NSURL*)url method:(NSString*)method params:(NSDictionary*)params;
+(NSData*)syncRequestDataFromURL:(NSURL*)url method:(NSString*)method requestBody:(NSString*)bodyString;

@end
