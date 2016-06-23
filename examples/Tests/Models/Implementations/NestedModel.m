//
//  NestedModel.m
//  JSONModelDemo
//
//  Created by Marin Todorov on 02/12/2012.
//  Copyright (c) 2012 Underplot ltd. All rights reserved.
//

#import "NestedModel.h"
#import "ImageModel.h"

@implementation NestedModel
@end

@implementation NestedModelWithoutProtocols

+ (Class)classForCollectionProperty:(NSString *)propertyName
{
    if ([propertyName isEqualToString:@"images"])
        return [ImageModel class];
    if ([propertyName isEqualToString:@"imagesObject"])
        return [ImageModel class];
    return nil;
}

@end
