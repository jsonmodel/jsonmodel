//
//  JSONCacheResponse.m
//  JSONModelDemo_iOS
//
//  Created by Marin Todorov on 3/25/13.
//  Copyright (c) 2013 Underplot ltd. All rights reserved.
//

#import "JSONCacheResponse.h"

@implementation JSONCacheResponse

-(instancetype)init
{
    self = [super init];
    if (self!=nil) {
        self.object = nil;
        self.isOfflineVersion = YES;
        self.mustRevalidate = NO;
        self.revalidateHeaders = [NSMutableDictionary dictionaryWithCapacity:2];
    }
    return self;
}

@end
