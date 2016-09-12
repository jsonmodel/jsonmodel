//
//  GitHubRepoModelForUSMapper.m
//  JSONModelDemo
//
//  Created by Marin Todorov on 21/12/2012.
//  Copyright (c) 2012 Underplot ltd. All rights reserved.
//

#import "GitHubRepoModelForUSMapper.h"

@implementation GitHubRepoModelForUSMapper

+(JSONKeyMapper*)keyMapper
{
	return [JSONKeyMapper mapperForSnakeCase];
}

@end
