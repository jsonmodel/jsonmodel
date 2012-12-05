//
//  JSONAPI.h
//  JSONModelDemo
//
//  Created by Marin Todorov on 05/12/2012.
//  Copyright (c) 2012 Underplot ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JSONHTTPClient.h"

@interface JSONAPI : NSObject

+(void)setAPIBaseURLWithString:(NSString*)base;
+(void)setContentType:(NSString*)ctype;

+(id)getWithPath:(NSString*)path andParams:(NSDictionary*)params;
+(id)postWithPath:(NSString*)path andParams:(NSDictionary*)params;

@end
