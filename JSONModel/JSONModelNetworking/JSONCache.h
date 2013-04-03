//
//  JSONCache.h
//  
//  @version 0.9.0
//  @author Marin Todorov, http://www.touch-code-magazine.com
//

// Copyright (c) 2012 Marin Todorov, Underplot ltd.
// This code is distributed under the terms and conditions of the MIT license.
//
// Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
// The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
//
// The MIT License in plain English: http://www.touch-code-magazine.com/JSONModel/MITLicense

#import <Foundation/Foundation.h>
#import "JSONCacheFile.h"
#import "JSONCacheResponse.h"

//use these when setting the cache revalidation times
extern float kNeverRevalidate;
extern float kAlwaysRevalidate;

//use these when setting the cache expiration times
extern float kNeverExpire;
extern float kImmediatelyExpire;

/**
 * Cache engine for your JSON based API - it helps you easily get local cache,
 * offline cache, and also get time or etag based server revalidation.
 *
 * You can use this class with <JSONHTTPClient> or separately with your own code.
 *
 * The basic idea behine JSONCache are the hard-expiration and soft-expiration times.
 * You set hard-expiration (by setting **expirationTimeInHours** and **expirationTimeInHoursWhenOffline**
 * so that objects in the cache are considered expired after the given amount of time
 * but the amount of time could be different depending whether the user is online or offline
 * (this is mostly applicable on the iPhone).
 *
 * Here's a short example how to set your <JSONHTTPClient> and <JSONAPI> to support 
 * caching API responses for 30 minutes, but keep all objects practicly forever cached
 * when the user is not connected to Internet (aka providing offline mode for your app)
 * <pre>
 * [JSONCache sharedCache].expirationTimeInHours = 0.5;
 * [JSONCache sharedCache].expirationTimeInHoursWhenOffline = kNeverExpire;
 * [JSONHTTPClient setIsUsingJSONCache: YES];
 *
 * [[JSONCache sharedCache] loadCacheFromDisc];
 *
 * [JSONAPI postWithPath:@"/getObjects" andParams:nil completion:... 
 * ... here use JSONAPI or JSONHTTPClient normally ...
 * ... the cache is already working with them with the config you've set ...
 * </pre>
 *
 * NB: If you are persisting your cache between app sessions (the common case) for apps
 * with offline mode, do not forget after configuring the cache, to load the cached files
 * from the device's disc: [[JSONCache sharedCache] loadCacheFromDisc]
 * 
 * If you want to check what are the cached objects in the cache right now: 
 * <pre>
 * NSLog(@"Cache: %@", [JSONCache sharedCache]);
 * </pre>
 * Setting your cache to automatically use server re-validation works in a similar fashion
 * you just need to use **revalidateCacheFromServerAfterTimeInHours** or **revalidateCacheViaETagAfterTimeInHours**
 * but for this to work you also will need to adjust your backend logic.
 */
@interface JSONCache : NSObject

@property (assign, nonatomic, readonly) BOOL isOnline;

@property (assign, nonatomic) float expirationTimeInHours;
@property (assign, nonatomic) float expirationTimeInHoursWhenOffline;

@property (assign, nonatomic) float revalidateCacheFromServerAfterTimeInHours;
@property (assign, nonatomic) float revalidateCacheViaETagAfterTimeInHours;

@property (assign, nonatomic) BOOL isUsingXdHTTPHeaderNames;

+(instancetype)sharedCache;

-(void)loadCacheFromDisc;

-(BOOL)addObject:(id)object forMethod:(NSString*)method andParams:(id)params;
-(BOOL)addObject:(id)object forMethod:(NSString*)method andParams:(id)params etag:(NSString*)etag;

-(JSONCacheResponse*)objectForMethod:(NSString*)method andParams:(id)params;

-(void)trimExpiredObjects;
-(void)trimObjectForKey:(NSString*)key;

-(void)purgeCache;

//helper methods
-(NSString*)etagHeaderName;

@end
