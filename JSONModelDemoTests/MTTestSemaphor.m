//
//  MTTestSemaphor.m
//
//  Created by Marin Todorov on 17/01/2012.
//  Copyright (c) 2012 Marin Todorov. All rights reserved.
//

#import "MTTestSemaphor.h"

@implementation MTTestSemaphor
{
    NSMutableDictionary* flags;
}

+(instancetype)semaphore
{   
    static MTTestSemaphor *sharedInstance = nil;
    static dispatch_once_t once;
    
    dispatch_once(&once, ^{
        sharedInstance = [MTTestSemaphor alloc];
        sharedInstance = [sharedInstance _initPrivate];
    });
    
    return sharedInstance;
}

-(id)_initPrivate
{
    self = [super init];
    if (self != nil) {
        flags = [NSMutableDictionary dictionaryWithCapacity:10];
    }
    return self;
}

-(BOOL)isLifted:(NSString*)key
{
    return [flags objectForKey:key]!=nil;
}

-(void)lift:(NSString*)key
{
    [flags setObject:@"YES" forKey: key];
}

-(void)waitForKey:(NSString*)key
{
    BOOL keepRunning = YES;
    while (keepRunning && [[NSRunLoop currentRunLoop] runMode: NSDefaultRunLoopMode beforeDate:[NSDate dateWithTimeIntervalSinceNow:1.0]]) {
        keepRunning = ![[MTTestSemaphor semaphore] isLifted: key];
    }

}

@end
