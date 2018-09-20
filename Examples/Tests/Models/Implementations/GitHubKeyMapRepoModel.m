//
//  GitHubKeyMapRepoModel.m
//  JSONModelDemo
//
//  Created by Marin Todorov on 19/12/2012.
//  Copyright (c) 2012 Underplot ltd. All rights reserved.
//

#import "GitHubKeyMapRepoModel.h"

@implementation GitHubKeyMapRepoModel

+(JSONKeyMapper*)keyMapper
{
	return [[JSONKeyMapper alloc] initWithKeyMappingBlock:^NSString *(Class cls, NSString *modelKey)
	{
		if ([modelKey isEqual:@"__description"])
			return @"description";
		else
			return modelKey;
	}];
}

@end
