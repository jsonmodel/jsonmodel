//
//  TestSemaphor.m
//  BillsApp
//
//  Created by Marin Todorov on 17/01/2012.
//  Copyright (c) 2012 Marin Todorov. All rights reserved.
//

#import "JSONModelSemaphore.h"

static NSMutableDictionary* flags = nil;

@implementation JSONModelSemaphore

+(JSONModelSemaphore *)sharedInstance
{   
    static JSONModelSemaphore *sharedInstance = nil;
    static dispatch_once_t once;
    
    dispatch_once(&once, ^{

        flags = [NSMutableDictionary dictionaryWithCapacity:10];
        sharedInstance = [[JSONModelSemaphore alloc] init];
    });
    
    return sharedInstance;
}

-(BOOL)isLifted:(NSString*)key
{
    return [flags objectForKey:key]!=nil;
}

-(void)lift:(NSString*)key
{
    NSLog(@"LIFT key: %@", key);
    [flags setObject:@"YES" forKey: key];
}

-(void)waitForKey:(NSString*)key
{
    NSLog(@"WAIT key: %@",key);
    BOOL keepRunning = YES;
    
    while (keepRunning && [[NSRunLoop currentRunLoop] runMode: NSDefaultRunLoopMode beforeDate:[NSDate dateWithTimeIntervalSinceNow:0.5]]) {
        NSLog(@"keep running with flags: %@",flags);
        keepRunning = ![[JSONModelSemaphore sharedInstance] isLifted: key];
    }
    NSLog(@"WAIT FINISH key: %@", key);
    //finished destroy the semaphor key
    [flags removeObjectForKey:key];
}

@end
