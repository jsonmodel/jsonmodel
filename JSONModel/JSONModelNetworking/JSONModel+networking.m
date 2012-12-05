//
//  JSONModel+networking.m
//  JSONModelDemo
//
//  Created by Marin Todorov on 04/12/2012.
//  Copyright (c) 2012 Underplot ltd. All rights reserved.
//

#import "JSONModel+networking.h"
#import "JSONHTTPClient.h"

@interface JSONModel ()

@end

@implementation JSONModel(networking)

-(id)initFromURLWithString:(NSString*)urlString
{
    id jsonObject = [JSONHTTPClient getJSONFromURLWithString:urlString];
    return [self initWithDictionary:jsonObject];
}

@end
