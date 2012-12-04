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
    requestId++;
    
    NSString* semaphorKey = [NSString stringWithFormat:@"rid: %ld", requestId];
    
    __block NSDictionary* json = nil;
    
    //1
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        //code executed in the background
        //2
        NSData* ytData = [NSData dataWithContentsOfURL:
                          [NSURL URLWithString:urlString]
                          //[NSURL URLWithString:@"http://touch-code-magazine.com"]
                          //[NSURL URLWithString:@"http://gdata.youtube.com/feeds/api/videos?q=pomplamoose&max-results=15&alt=json"]
                          ];
        //3
        if (ytData) {
            
            //catch exception and lift flag
            
            json = [NSJSONSerialization
                    JSONObjectWithData:ytData
                    options:kNilOptions
                    error:nil];
        }
        
        //4
        //dispatch_async(dispatch_get_main_queue(), ^{
            //code executed on the main queue
            //5
            
            [[JSONModelSemaphore sharedInstance] lift: semaphorKey ];
        //});
        
    });
    
    
    [[JSONModelSemaphore sharedInstance] waitForKey: semaphorKey ];
    
    return json;
}



@end
