//
//  MultipleModel.m
//  Examples
//
//  Created by Seamus on 2018/3/1.
//  Copyright © 2018年 JSONModel. All rights reserved.
//

#import "MultipleModel.h"
@class MultipleCarModel;
@class MultiplePicModel;

@implementation MultipleModel

+ (Class)classForModel:(NSDictionary *)dict
{
	if ([[dict valueForKey:@"typeField"] isEqualToString:@"picture"]) {
		return [MultiplePicModel class];
	}
	else if ([[dict valueForKey:@"typeField"] isEqualToString:@"car"]) {
		return [MultipleCarModel class];
	}
	return [self class];
}
@end

@implementation MultiplePicModel

@end

@implementation MultipleCarModel

@end

@implementation MultipleTestModel
+ (Class)classForCollectionProperty:(NSString *)propertyName
{
	if ([propertyName isEqualToString:@"models"])
		return [MultipleModel class];
	return nil;
}
@end
