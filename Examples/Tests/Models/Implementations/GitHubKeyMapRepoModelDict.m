//
//  GitHubKeyMapRepoModelDict.m
//  JSONModelDemo
//
//  Created by Marin Todorov on 20/12/2012.
//  Copyright (c) 2012 Underplot ltd. All rights reserved.
//

#import "GitHubKeyMapRepoModelDict.h"

@implementation GitHubKeyMapRepoModelDict

+(JSONKeyMapper*)keyMapper
{
	return [[JSONKeyMapper alloc] initWithModelToJSONDictionary:@{@"__description":@"description"}];
}

@end
