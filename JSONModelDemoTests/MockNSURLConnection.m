//
//  MockNSURLConnection.m
//  JSONModelDemo_iOS
//
//  Created by Marin Todorov on 3/26/13.
//  Copyright (c) 2013 Underplot ltd. All rights reserved.
//

#import "MockNSURLConnection.h"

static NSURLResponse* nextResponse = nil;
static NSError* nextError = nil;
static NSData* nextData = nil;
static NSURLRequest* lastRequest = nil;

@interface NSURLConnection (MockPrivate)

@end

@implementation NSURLConnection(Mock)

+(void)setNextResponse:(NSURLResponse*)response data:(NSData*)data error:(NSError*)error
{
    nextResponse = response;
    nextData = data;
    nextError = error;
}

+(NSURLRequest*)lastRequest
{
    return lastRequest;
}

+ (NSData *)sendSynchronousRequest:(NSURLRequest *)request returningResponse:(NSURLResponse **)response error:(NSError **)error
{
    lastRequest = request;
    *response = nextResponse;
    *error = nextError;
    return nextData;
}

@end
