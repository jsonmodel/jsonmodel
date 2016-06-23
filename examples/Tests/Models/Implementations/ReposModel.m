//
//  ReposModel.m
//  JSONModelDemo
//
//  Created by Marin Todorov on 19/12/2012.
//  Copyright (c) 2012 Underplot ltd. All rights reserved.
//

#import "ReposModel.h"

@implementation ReposModel
@end

@implementation ReposProtocolArrayModel

#pragma GCC diagnostic push
#pragma GCC diagnostic ignored "-Wdeprecated-implementations"
+(NSString*)protocolForArrayProperty:(NSString *)propertyName
#pragma GCC diagnostic pop
{
	if ([propertyName isEqualToString:@"repositories"]) {
		return @"GitHubRepoModel";
	}
	return nil;
}

@end
