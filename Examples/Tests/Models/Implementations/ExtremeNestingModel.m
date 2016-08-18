//
// Created by Rahul Somasunderam on 9/4/14.
// Copyright (c) 2014 Underplot ltd. All rights reserved.
//

#import "ExtremeNestingModel.h"

@implementation ExtremeNestingModel

+(JSONKeyMapper*)keyMapper
{
	return [[JSONKeyMapper alloc] initWithModelToJSONDictionary:@
	{
		@"drugs" : @"generic_alternatives.items.data"
	}];
}

@end
