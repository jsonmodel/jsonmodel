//
//  OptionalPropModel.m
//  JSONModelDemo
//
//  Created by Marin Todorov on 02/12/2012.
//  Copyright (c) 2012 Underplot ltd. All rights reserved.
//

#import "OptionalPropModel.h"

@implementation OptionalPropModel

+(BOOL)propertyIsOptional:(NSString*)propertyName
{
	if ([super propertyIsOptional:propertyName])
		return YES;

	if ([propertyName isEqualToString:@"notRequiredPoint"])
		return YES;

	return NO;
}

@end
