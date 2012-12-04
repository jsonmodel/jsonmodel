//
//  JSONModelHTTPClient.m
//  JSONModelDemo
//
//  Created by Marin Todorov on 04/12/2012.
//  Copyright (c) 2012 Underplot ltd. All rights reserved.
//

#import "JSONModelHTTPClient.h"
#import "JSONModelSemaphore.h"

static long requestId = 0;

@implementation JSONModelHTTPClient

+(id)getJSONFromURLWithString:(NSString*)urlString
{
    return [self getJSONFromURL:[NSURL URLWithString:urlString]];
}

+(id)getJSONFromURL:(NSURL*)url
{
    requestId++;
    
    NSString* semaphorKey = [NSString stringWithFormat:@"rid: %ld", requestId];
    
    __block NSDictionary* json = nil;
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{

        NSData* ytData = [NSData dataWithContentsOfURL: url];

        if (ytData) {
            
            //catch exception and lift flag
            
            json = [NSJSONSerialization
                    JSONObjectWithData:ytData
                    options:kNilOptions
                    error:nil];
        }
        
        [[JSONModelSemaphore sharedInstance] lift: semaphorKey ];
        
    });
    
    [[JSONModelSemaphore sharedInstance] waitForKey: semaphorKey ];
    
    return json;
}



@end
