//
//  JSONCache.m
//  
//  @version 0.8.4
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

#import "JSONModel.h"
#import "JSONCache.h"
#import <CommonCrypto/CommonDigest.h>
#import <SystemConfiguration/SystemConfiguration.h>

#import <netinet/in.h>
#import <netinet6/in6.h>

#define kJSONCacheDirectory @"JSONCache"
#define kDefaultExpirationTimeInHours 1 //1 day
#define kDefaultExpirationTimeInHoursWhenOffline 168 //1 week

static JSONCache* instance = nil;

#pragma mark - cache implementation

@implementation JSONCache
{
    NSString* cacheDirectory;
    NSFileManager* fm;

    NSMutableDictionary* cacheFiles;
    
    NSTimeInterval _expirationOnlineTimeInterval;
    NSTimeInterval _expirationOfflineTimeInterval;
    
    SCNetworkReachabilityRef reachabilityRef;
    BOOL observingConnection;
}

-(instancetype)init
{
    NSAssert(NO, @"use [JSONCache sharedCache] instead");
    return nil;
}

+(instancetype)sharedCache
{
    static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		instance = [[[self class] alloc] _initPrivate];
	});
    return instance;
}

-(id)_initPrivate
{
    self = [super init];
    if (self!=nil) {
                
        //do initial configuration
        self.expirationTimeInHours = kDefaultExpirationTimeInHours;
        self.expirationTimeInHoursWhenOffline = kDefaultExpirationTimeInHoursWhenOffline;
        
        //setup the directories
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory , NSUserDomainMask, YES);
        cacheDirectory = [[paths objectAtIndex:0] stringByAppendingPathComponent:kJSONCacheDirectory];
        
        fm = [[NSFileManager alloc] init];
        
        //create the cache directory
        if (![fm fileExistsAtPath:cacheDirectory]) {
            //empty cache
            [fm createDirectoryAtPath:cacheDirectory withIntermediateDirectories:YES attributes:nil error:nil];
            cacheFiles = [[NSMutableDictionary alloc] initWithCapacity:10];
            
        } else {
            //read the current cache folder
            NSArray *directoryContents = [fm contentsOfDirectoryAtPath:cacheDirectory error:nil];
            
            cacheFiles = [[NSMutableDictionary alloc] initWithCapacity: directoryContents.count];
            
            //read the current cache contents
            for (NSString* fileName in directoryContents) {
                NSString* fullFilePath = [cacheDirectory stringByAppendingPathComponent: fileName];
                NSDate* modifiedDate = [[fm attributesOfItemAtPath:fullFilePath error:NULL] fileModificationDate];
                
                JSONCacheFile* file = [[JSONCacheFile alloc] init];
                file.modificationTime= [modifiedDate timeIntervalSinceReferenceDate];
                file.name = fileName;
                
                [cacheFiles setValue:file forKey:fileName];
            }
            
            //trim the cache
            [self trimExpiredObjects];
        }
        
        if (cacheFiles.count>0 && observingConnection==NO) {
            //observe connectivity changes
            [self startConnectivityObserver];
            JMLog(@"JSONCache.isOnline = %@", _isOnline?@"YES":@"NO");
        }
    }
    
    return self;
}

-(BOOL)addObject:(id)object forMethod:(NSString*)method andParams:(id)params
{
    //expire objects
    [self trimExpiredObjects];
    
    //add new objects
    NSString* key = [self keyForMethod:method andParams:params];
    
    //store the file
    NSString* filePath = [cacheDirectory stringByAppendingPathComponent:key];
    NSData * data = [NSKeyedArchiver archivedDataWithRootObject:object];

    BOOL success = [data writeToFile:filePath atomically:YES];
    if (success) {
        //save the cache file
        JSONCacheFile* file = [[JSONCacheFile alloc] init];
        file.name = key;
        file.modificationTime = [[NSDate date] timeIntervalSinceReferenceDate];
        [cacheFiles setValue: file forKey:key];
    }
    
    if (cacheFiles.count>0 && observingConnection==NO) {
        //observe connectivity changes
        [self startConnectivityObserver];
        JMLog(@"JSONCache.isOnline = %@", _isOnline?@"YES":@"NO");
    }

    return success;
}

-(id)objectForMethod:(NSString*)method andParams:(id)params
{
    NSString* key = [self keyForMethod:method andParams:params];
    JSONCacheFile* file = cacheFiles[key];
    
    if (!file) return nil;

    if ([self isObjectExpired: file]) {
        //expired content
        [self trimObjectForKey: key];
        return nil;
    }
    
    NSString* filePath = [cacheDirectory stringByAppendingPathComponent:key];
    NSData* data = [NSData dataWithContentsOfFile: filePath];
    id result = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    return result;
}

-(NSString*)keyForMethod:(NSString*)method andParams:(id)params
{
    if (params==nil) return method;
    
    NSData* data = [NSJSONSerialization dataWithJSONObject: @{@"m":method,@"p":params}
                                                   options: kNilOptions error:NULL];
    
    NSString* key = [[NSString alloc] initWithData:data encoding: NSUTF8StringEncoding];
    return [self MD5:key];
}

-(void)trimExpiredObjects
{
    for (NSString* key in [cacheFiles allKeys]) {
        if ([self isObjectExpired: cacheFiles[key]]) {
            //expired content
            [self trimObjectForKey: key];
        }
    }
}

-(void)trimObjectForKey:(NSString*)key
{
    NSString* filePath = [cacheDirectory stringByAppendingPathComponent:key];
    [fm removeItemAtPath:filePath error:NULL];
    [cacheFiles removeObjectForKey: key];
    
    if (cacheFiles.count==0 && observingConnection==YES) {
        //observe connectivity changes
        [self stopConnectivityObserver];
    }

}

-(void)purgeCache
{
    for (NSString* key in [cacheFiles allKeys]) {
        [self trimObjectForKey: key];
    }
}

#pragma mark - connectivity methods
static void ReachabilityCallback(SCNetworkReachabilityRef target, SCNetworkReachabilityFlags flags, void *info)
{
#pragma unused (target, flags, info)
    [instance updateConnectivity];
}

-(void)startConnectivityObserver
{
    if (reachabilityRef==NULL) {
        [self updateConnectivity];
    }
    SCNetworkReachabilityContext context = {0, (__bridge void *)(self), NULL, NULL, NULL};
    if(SCNetworkReachabilitySetCallback(reachabilityRef, ReachabilityCallback, &context))
    {
        if(SCNetworkReachabilityScheduleWithRunLoop(reachabilityRef, CFRunLoopGetCurrent(), kCFRunLoopDefaultMode))
        {
            observingConnection = YES;
        }
    }
}

-(void)stopConnectivityObserver
{
    if(reachabilityRef!= NULL)
    {
        SCNetworkReachabilityUnscheduleFromRunLoop(reachabilityRef, CFRunLoopGetCurrent(), kCFRunLoopDefaultMode);
    }
    observingConnection = NO;
}

-(void)updateConnectivity
{
    struct sockaddr_in zeroAddress;
    bzero(&zeroAddress, sizeof(zeroAddress));
    zeroAddress.sin_len = sizeof(zeroAddress);
    zeroAddress.sin_family = AF_INET;
    
    reachabilityRef = SCNetworkReachabilityCreateWithAddress(kCFAllocatorDefault, (const struct sockaddr*)&zeroAddress);
    
    if(reachabilityRef != NULL) {
        SCNetworkReachabilityFlags flags;
        if (SCNetworkReachabilityGetFlags(reachabilityRef, &flags)) {
            if ((flags & kSCNetworkReachabilityFlagsReachable) == 0)
            {
                _isOnline = NO;
                return;
            }
            
            if ((flags & kSCNetworkReachabilityFlagsConnectionRequired) == 0)
            {
                _isOnline = YES;
                return;
            }
            
            if ((((flags & kSCNetworkReachabilityFlagsConnectionOnDemand ) != 0) ||
                 (flags & kSCNetworkReachabilityFlagsConnectionOnTraffic) != 0))
            {
                if ((flags & kSCNetworkReachabilityFlagsInterventionRequired) == 0)
                {
                    _isOnline = YES;
                    return;
                }
            }
            
            if ((flags & kSCNetworkReachabilityFlagsIsWWAN) == kSCNetworkReachabilityFlagsIsWWAN)
            {
                _isOnline = YES;
                return;
            }
        }
    }
    
    _isOnline = NO;
}


#pragma mark - convenience methods
-(BOOL)isObjectExpired:(JSONCacheFile*)object
{
    NSTimeInterval now = [[NSDate date] timeIntervalSinceReferenceDate];
    NSTimeInterval expiration = 0;
    
    if (self.isOnline==NO && self.isOfflineCacheEnabled==NO) {
        
        //it's always expired
        return YES;
        
    } else if (self.isOnline==YES && self.isOfflineCacheEnabled==NO) {
        
        //online cache expiration
        expiration = _expirationOnlineTimeInterval;
        
    } else if (self.isOnline==YES && self.isOfflineCacheEnabled==YES) {

        //offline expiration time
        expiration = _expirationOfflineTimeInterval;
        
    } else {
        
        //just return the longer of the two exp. times
        expiration = MAX(_expirationOfflineTimeInterval, _expirationOnlineTimeInterval);
        
    }
    return (now > object.modificationTime + expiration);
}

//http://stackoverflow.com/questions/1524604/md5-algorithm-in-objective-c
-(NSString*)MD5:(NSString*)string
{
    
    const char *cStr = [string UTF8String];
    unsigned char result[16];
    CC_MD5( cStr, strlen(cStr), result );
    return [NSString stringWithFormat:
            @"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
            result[0], result[1], result[2], result[3],
            result[4], result[5], result[6], result[7],
            result[8], result[9], result[10], result[11],
            result[12], result[13], result[14], result[15]
            ];
}

-(NSString*)description
{
    return [cacheFiles description];
}

-(void)setExpirationTimeInHours:(int)expirationTimeInHours
{
    _expirationTimeInHours = expirationTimeInHours;
    _expirationOnlineTimeInterval = expirationTimeInHours * 360;
}

-(void)setExpirationTimeInHoursWhenOffline:(int)expirationTimeInHoursWhenOffline
{
    _expirationTimeInHoursWhenOffline = expirationTimeInHoursWhenOffline;
    _expirationOfflineTimeInterval = expirationTimeInHoursWhenOffline * 360;
}

@end

#pragma mark - helper classes
@implementation JSONCacheFile
-(NSString*)description
{
    return self.name;
}
@end
