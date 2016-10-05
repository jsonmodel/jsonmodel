//
//  RenamedPropertyModel.m
//  JSONModelDemo_iOS
//
//  Created by James Billingham on 16/12/2015.
//  Copyright © 2015 Underplot ltd. All rights reserved.
//

#import "RenamedPropertyModel.h"

@implementation RenamedPropertyModel

+ (JSONKeyMapper *)keyMapper
{
	JSONKeyMapper *base = [JSONKeyMapper mapperForTitleCase];
	return [JSONKeyMapper baseMapper:base withModelToJSONExceptions:@{@"identifier": @"ID"}];
}

@end
