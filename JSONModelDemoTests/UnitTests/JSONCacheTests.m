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

BOOL utJCFEqual(f1, f2) { return (fabs((f1) - (f2)) < FLT_EPSILON); }

@implementation JSONCacheTests
{
    NSString* imageJSON;
}

-(void)setUp
{
    //image json string for the response
    imageJSON = @"{\"idImage\": 2, \"name\": \"lake.jpg\"}";
}

-(void)testSingleton
{
    //test shared instance
    NSAssert([JSONCache sharedCache], @"shared cache not accesible");
}

-(void)testForcingConnectionStatus
{
    //test simulation for online/offline status
    [[JSONCache sharedCache] setForcedOnlineStatus:YES];
    NSAssert([JSONCache sharedCache].isOnline, @"simulating online status failed");
    [[JSONCache sharedCache] setForcedOnlineStatus:NO];
    NSAssert([JSONCache sharedCache].isOnline==NO, @"simulating offline status failed");
}

-(void)testEtagHeaderName
{
    //test header names configuration
    [JSONCache sharedCache].isUsingXdHTTPHeaderNames = YES;
    NSAssert([[JSONCache sharedCache].etagHeaderName isEqualToString:@"X-ETag"], @"no X-ETag header name set for cache");
    [JSONCache sharedCache].isUsingXdHTTPHeaderNames = NO;
    NSAssert([[JSONCache sharedCache].etagHeaderName isEqualToString:@"ETag"], @"no ETag header name set for cache");
}

-(void)testSettingTimeIntervals
{
    //test setting online exp. time
    [JSONCache sharedCache].expirationTimeInHours = 5;
    NSNumber* timeInterval = [[JSONCache sharedCache] valueForKey:@"_expirationOnlineTimeInterval"];
    NSAssert(utJCFEqual([timeInterval doubleValue], 5*360), @"expiration time interval ivar not set");
    
    [JSONCache sharedCache].expirationTimeInHours = kNeverExpire;
    timeInterval = [[JSONCache sharedCache] valueForKey:@"_expirationOnlineTimeInterval"];
    NSAssert(utJCFEqual([timeInterval doubleValue], kNeverExpire), @"expiration time interval ivar not set for never expire");
    
    //test setting offline exp. time
    [JSONCache sharedCache].expirationTimeInHoursWhenOffline = 6;
    timeInterval = [[JSONCache sharedCache] valueForKey:@"_expirationOfflineTimeInterval"];
    NSAssert(utJCFEqual([timeInterval doubleValue], 6*360), @"expiration time offline interval ivar not set");
    
    [JSONCache sharedCache].expirationTimeInHoursWhenOffline = kNeverExpire;
    timeInterval = [[JSONCache sharedCache] valueForKey:@"_expirationOfflineTimeInterval"];
    NSAssert(utJCFEqual([timeInterval doubleValue], kNeverExpire), @"expiration time offline interval ivar not set for never expire");

    //test setting time based revalidation time interval
    [JSONCache sharedCache].revalidateCacheFromServerAfterTimeInHours = 2;
    timeInterval = [[JSONCache sharedCache] valueForKey:@"_revalidateFromServerTimeInterval"];
    NSAssert(utJCFEqual([timeInterval doubleValue], 2*360), @"_revalidateFromServerTimeInterval was not properly set");
    
    [JSONCache sharedCache].revalidateCacheFromServerAfterTimeInHours = kNeverRevalidate;
    timeInterval = [[JSONCache sharedCache] valueForKey:@"_revalidateFromServerTimeInterval"];
    NSAssert(utJCFEqual([timeInterval doubleValue], kNeverRevalidate), @"_revalidateFromServerTimeInterval was not properly set for never revalidate");
    
    //test setting the etag revalidation interval
    [JSONCache sharedCache].revalidateCacheViaETagAfterTimeInHours = 4;
    timeInterval = [[JSONCache sharedCache] valueForKey:@"_revalidateFromServerWithETagTimeInterval"];
    NSAssert(utJCFEqual([timeInterval doubleValue], 4*360), @"_revalidateFromServerWithETagTimeInterval was not properly set");
    
    [JSONCache sharedCache].revalidateCacheViaETagAfterTimeInHours = kNeverRevalidate;
    timeInterval = [[JSONCache sharedCache] valueForKey:@"_revalidateFromServerWithETagTimeInterval"];
    NSAssert(utJCFEqual([timeInterval doubleValue], kNeverRevalidate), @"_revalidateFromServerWithETagTimeInterval was not properly set for never revalidate");
}

-(void)test
{
    
}

-(void)tearDown
{
    
}


@end
