//
//  VideoModel.m
//  JSONModelDemo
//
//  Created by Marin Todorov on 02/12/2012.
//  Copyright (c) 2012 Underplot ltd. All rights reserved.
//

#import "VideoModel.h"

@implementation VideoModel

-(id)initWithDictionary:(NSDictionary*)d error:(NSError *__autoreleasing *)err
{
    self = [super init];
    
    if (self) {
        self.title = [[VideoTitle alloc] initWithDictionary: d[@"title"] error:err];
        if (!self.title) return nil;
        
        self.link = [[VideoLink alloc] initWithDictionary: d[@"link"][0] error:err];
        if (!self.link) return nil;
    }
    
    return self;
}

@end
