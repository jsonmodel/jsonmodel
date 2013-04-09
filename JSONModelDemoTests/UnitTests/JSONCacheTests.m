//
//  JSONCacheTests.m
//  JSONModelDemo_iOS
//
//  Created by Marin Todorov on 4/9/13.
//  Copyright (c) 2013 Underplot ltd. All rights reserved.
//

#import "JSONCacheTests.h"
#import "JSONModelLib.h"
#import "MockNSURLConnection.h"
#import "MTTestSemaphor.h"

#import "ImageModel.h"

//---------------------------------------
// Overriding some JSONCache methods for the tests to run successfuly
// Simulating online/offline state, etc.
//---------------------------------------
@interface JSONCache(unit_testing)
-(void)setForcedOnlineStatus:(BOOL)forceStateIsOnline;
@end

@implementation JSONCache(unit_testing)
-(void)setForcedOnlineStatus:(BOOL)forceStateIsOnline
{
    [self setValue:@(forceStateIsOnline) forKey:@"isOnline"];
}
@end


@implementation JSONCacheTests
{
    NSString* imageJSON;
}

-(void)setUp
{
    //image json string for the response
    imageJSON = @"{\"idImage\": 2, \"name\": \"lake.jpg\"}";
}

-(void)testSettingUp
{
    //test shared instance
    NSAssert([JSONCache sharedCache], @"shared cache not accesible");
    
    //test simulation for online/offline status
    [[JSONCache sharedCache] setForcedOnlineStatus:YES];
    NSAssert([JSONCache sharedCache].isOnline, @"simulating online status failed");
    [[JSONCache sharedCache] setForcedOnlineStatus:NO];
    NSAssert([JSONCache sharedCache].isOnline==NO, @"simulating offline status failed");
    
    //test header names configuration
    [JSONCache sharedCache].isUsingXdHTTPHeaderNames = YES;
    NSAssert([[JSONCache sharedCache].etagHeaderName isEqualToString:@"X-ETag"], @"no X-ETag header name set for cache");
    [JSONCache sharedCache].isUsingXdHTTPHeaderNames = NO;
    NSAssert([[JSONCache sharedCache].etagHeaderName isEqualToString:@"ETag"], @"no ETag header name set for cache");
    
    [JSONCache sharedCache].expirationTimeInHours = 5;
    //TODO: inspect the values of the expiration intervals by using object_getInstanceVariable
    
    //object_getInstanceVariable([JSONCache sharedCache], "_expirationOnlineTimeInterval", outValue);
    //NSLog(@"result: %.f", result);
    
}

-(void)tearDown
{
    
    
    
}


@end
