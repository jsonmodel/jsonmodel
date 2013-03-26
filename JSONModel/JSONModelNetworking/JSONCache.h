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

extern int kNeverRevalidate;
extern int kAlwaysRevalidate;

extern int kNeverExpire;
extern int kImmediatelyExpire;

@interface JSONCache : NSObject

@property (assign, nonatomic, readonly) BOOL isOnline;

@property (assign, nonatomic) int expirationTimeInHours;
@property (assign, nonatomic) int expirationTimeInHoursWhenOffline;

@property (assign, nonatomic) BOOL isOfflineCacheEnabled;

@property (assign, nonatomic) int revalidateCacheFromServerAfterTimeInHours;
@property (assign, nonatomic) int revalidateCacheViaETagAfterTimeInHours;

@property (assign, nonatomic) BOOL isUsingXdHTTPHeaderNames;

+(instancetype)sharedCache;

-(BOOL)addObject:(id)object forMethod:(NSString*)method andParams:(id)params;
-(BOOL)addObject:(id)object forMethod:(NSString*)method andParams:(id)params etag:(NSString*)etag;

-(JSONCacheResponse*)objectForMethod:(NSString*)method andParams:(id)params;

-(void)trimExpiredObjects;
-(void)trimObjectForKey:(NSString*)key;

-(void)purgeCache;

//helper methods
-(NSString*)etagHeaderName;

@end
