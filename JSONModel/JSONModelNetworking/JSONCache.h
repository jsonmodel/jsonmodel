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

#pragma mark - expire/revalidate constants
//use these when setting the cache revalidation times
extern float kNeverRevalidate;
extern float kAlwaysRevalidate;

//use these when setting the cache expiration times
extern float kNeverExpire;
extern float kImmediatelyExpire;

#pragma mark - interface
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
 * //config expiration times
 * [JSONCache sharedCache].expirationTimeInHours = 0.5;
 * [JSONCache sharedCache].expirationTimeInHoursWhenOffline = kNeverExpire;
 *
 * //tell JSONHTTPClient to use JSONCache
 * [JSONHTTPClient setIsUsingJSONCache: YES];
 *
 * //load the currently cached on disc objects
 * [[JSONCache sharedCache] loadCacheFromDisc];
 *
 * [JSONAPI postWithPath:@"/getObjects" andParams:nil completion:... 
 * ... here use JSONAPI or JSONHTTPClient normally ...
 * ... the cache is already working with them with the config you've set ...
 * </pre>
 *
 * **NB**: If you are persisting your cache between app sessions (the common case) for apps
 * with offline mode, do not forget after configuring the cache, to load the cached files
 * from the device's disc: [[JSONCache sharedCache] loadCacheFromDisc]
 * 
 * If you want to check what's in the cache right now: 
 * <pre>
 * NSLog(@"Cache: %@", [JSONCache sharedCache]);
 * </pre>
 * Setting your cache to automatically use server re-validation works in a similar fashion
 * you just need to use **revalidateCacheFromServerAfterTimeInHours** or **revalidateCacheViaETagAfterTimeInHours**
 * but for this to work you also will need to adjust your backend logic.
 */
@interface JSONCache : NSObject

/** @name Access shared cache */
/** Shared instance for you to use */
+(instancetype)sharedCache;

#pragma mark - network status
/** @name Check network status */
/**
 * Indicates whether a network connection is available. 
 *
 * This property also indicates whether the cache is using currently
 * the offline or online expiration age for the objects in the cache
 */
@property (assign, nonatomic, readonly) BOOL isOnline;

#pragma mark - configuration
/** @name Configuring JSONCache */
/** The expiration age in hours of the cached objects when Online */
@property (assign, nonatomic) float expirationTimeInHours;

/** The expiration age in hours of the cached objects when Offline */
@property (assign, nonatomic) float expirationTimeInHoursWhenOffline;

/** 
 * When set, the cache returns a cached object, but instructs the client it should
 * revalidate with the server, using time based revalidation.
 *
 * When the cached object is older than the set age JSONHTTPClient will send an HTTP header like this:
 * <pre>If-Modified-Since: 2012-11-05T08:15:30-05:00</pre>
 * and if **isUsingXdHTTPHeaderNames** is set to YES the header has a "X-" prefix:
 * <pre>X-If-Modified-Since: 2012-11-05T08:15:30-05:00</pre>
 */
@property (assign, nonatomic) float revalidateCacheFromServerAfterTimeInHours;

/**
 * When set, the cache returns a cached object, but instructs the client it should
 * revalidate with the server; using the etag for that object that the client received from the server.
 *
 * When the cached object is older than the set age JSONHTTPClient will send an HTTP header like this:
 * <pre>ETag: akjfk248488kejfh-199999</pre>
 * and if **isUsingXdHTTPHeaderNames** is set to YES the header has a "X-" prefix:
 * <pre>X-ETag: akjfk248488kejfh-199999</pre>
 */
@property (assign, nonatomic) float revalidateCacheViaETagAfterTimeInHours;

/**
 * When set to YES the HTTP headers sent for revalidation at the server side
 * are prefixed with an "X-"; the "ETag" and "If-Modified-Since" headers become
 * "X-ETag" and "X-If-Modified-Since"
 */
@property (assign, nonatomic) BOOL isUsingXdHTTPHeaderNames;

#pragma mark - load existing files
/** @name Load the existing cached files */
/** Load the cached objects persisted on disc */
-(void)loadCacheFromDisc;

#pragma mark - manage cache objects
/** @name Manage cached objects */
/**
 * Add an object to the cache
 *
 * This is how you add an object to the cache; this object could be a JSON string, NSDictionary or other.
 * The **method** and **params** are suited for HTTP calls, ie. GET method and nil params, or POST method
 * and the POST params: @{@"name":@"user1", @"address":@"125 Locker Str"}, etc. The combination of the method
 * and parameters are used to uniquely identify the cached object in the cache.
 *
 * **NB**: If you use [<JSONHTTPClient> isUsingJSONCache:YES], then you don't need to call this method yourself,
 * it's invoked automatically by JSONHTTPClient
 * @param object The object to add
 * @param method The method used to get the object
 * @param params Any object representing the params used to get the object
 * @return Whether the object was added successfuly
 */
-(BOOL)addObject:(id)object forMethod:(NSString*)method andParams:(id)params;

/**  
 * Add an object to the cache with an etag attached to it.
 *
 * Look at documentation of <[JSONCache addObject:forMethod:andParams:]>; the only benefit of this method
 * is that you can also supply an etag to attached to the cached object.
 *
 * **NB**: If you use [<JSONHTTPClient> isUsingJSONCache:YES], then you don't need to call this method yourself,
 * it's invoked automatically by JSONHTTPClient
 * @param object The object to add
 * @param method The method used to get the object
 * @param params Any object representing the params used to get the object
 * @param etag An ETag string to identify the cached object when revalidating with the server
 * @return Whether the object was added successfuly
 */
-(BOOL)addObject:(id)object forMethod:(NSString*)method andParams:(id)params etag:(NSString*)etag;

/**
 * Fetch a cache response object for given method and parameters. Use this method to look for cached objects in the cache.
 *
 * **NB**: If you use [<JSONHTTPClient> isUsingJSONCache:YES], then you don't need to call this method yourself,
 * it's invoked automatically by JSONHTTPClient
 * @param method The method used to get the object
 * @param params Any object representing the params used to get the object
 * @return Response object from the cache of class <JSONCacheResponse>. It includes the cached object
 * if one is found, headers to send to the server if revalidating, etc.
 */
-(JSONCacheResponse*)objectForMethod:(NSString*)method andParams:(id)params;

/** Delete the objects from the cache that are expired as of now */
-(void)trimExpiredObjects;

/**
 * Delete a specific object from the cache
 * @param method The method used to get the object
 * @param params Any object representing the params used to get the object
 */
-(void)trimObjectForMethod:(NSString*)method andParams:(id)params;

/** Delete all objects currently in the cache */
-(void)purgeCache;

#pragma mark - helpers
/** @name Get the etag header name */
/**
 * Returns either "ETag" or "X-ETag" depending on the value of **isUsingXdHTTPHeaderNames** 
 * 
 * JSONHTTPClient uses this method when fetching the etag for objects coming from the API. 
 * Normally you won't need to call this method.
 * @return The etag header name used: "ETag" or "X-ETag"
 */
-(NSString*)etagHeaderName;

@end
