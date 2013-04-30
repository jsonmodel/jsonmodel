//
//  MockNSURLConnection.m
//  JSONModelDemo_iOS
//
//  Created by Marin Todorov on 3/26/13.
//  Copyright (c) 2013 Underplot ltd. All rights reserved.
//

#import "MockNSURLConnection.h"
#import "MTTestSemaphor.h"

static NSHTTPURLResponse* nextResponse = nil;
static NSError* nextError = nil;
static NSData* nextData = nil;
static NSURLRequest* lastRequest = nil;

static int responseDelayInSeconds = 0;

@implementation NSURLConnection(Mock)

+(void)setNextResponse:(NSHTTPURLResponse*)response data:(NSData*)data error:(NSError*)error
{
    nextResponse = response;
    nextData = data;
    nextError = error;
}

+(NSURLRequest*)lastRequest
{
    return lastRequest;
}

+ (NSData *)sendSynchronousRequest:(NSURLRequest *)request returningResponse:(NSHTTPURLResponse **)response error:(NSError **)error
{
    if (responseDelayInSeconds>0) {
        [NSThread sleepForTimeInterval: responseDelayInSeconds];
    }
    
    lastRequest = request;
    *response = nextResponse;
    *error = nextError;
    return nextData;
}

+(void)setResponseDelay:(int)seconds
{
    responseDelayInSeconds = seconds;
}

@end
