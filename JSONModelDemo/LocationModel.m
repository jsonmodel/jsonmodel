//
//  LocationModel.m
//  JSONModel_Demo
//
//  Created by Marin Todorov on 26/11/2012.
//  Copyright (c) 2012 Underplot ltd. All rights reserved.
//

#import "LocationModel.h"
#import "JSONKeyMapper.h"

@implementation LocationModel

+(JSONKeyMapper*)keyMapper
{
    return [JSONKeyMapper mapperFromUnderscoreCaseToCamelCase];
}

@end