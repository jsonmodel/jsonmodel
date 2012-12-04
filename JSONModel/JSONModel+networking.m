//
//  JSONModel+networking.m
//  JSONModelDemo
//
//  Created by Marin Todorov on 04/12/2012.
//  Copyright (c) 2012 Underplot ltd. All rights reserved.
//

#import "JSONModel+networking.h"
#import "JSONModelHTTPClient.h"

@implementation JSONModel(networking)

-(id)initWithURL:(NSURL*)url
{
    id jsonObject = [JSONModelHTTPClient getJSONFromURL:url];
    
    if (!jsonObject) return nil;
    
    return [self initWithDictionary:jsonObject];
    
}

-(id)initWithURLString:(NSString*)urlString
{
    return [self initWithURL:[NSURL URLWithString:urlString]];
}

@end
