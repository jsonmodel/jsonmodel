//
//  EnumModel.m
//  JSONModelDemo_iOS
//
//  Created by Marin Todorov on 6/17/13.
//  Copyright (c) 2013 Underplot ltd. All rights reserved.
//

#import "EnumModel.h"

@implementation EnumModel

-(void)setStatusWithNSString:(NSString*)statusString
{
	_status = [statusString isEqualToString:@"open"]?StatusOpen:StatusClosed;
}

-(void)setNsStatusWithNSString:(NSString*)statusString
{
	_nsStatus = [statusString isEqualToString:@"open"]?NSE_StatusOpen:NSE_StatusClosed;
}

-(void)setNsuStatusWithNSString:(NSString*)statusString
{
	_nsuStatus = [statusString isEqualToString:@"open"]?NSEU_StatusOpen:NSEU_StatusClosed;
}

-(void)setNestedStatusWithNSString:(NSString*)statusString
{
	_status = [statusString isEqualToString:@"open"]?StatusOpen:StatusClosed;
}

-(void)setNestedStatusWithNSNumber:(NSNumber*)statusNumber
{
	_status = statusNumber.boolValue?StatusOpen:StatusClosed;
}

- (void)setNestedStatusWithJSONObject:(id <NSObject>)object
{
	if ([object isKindOfClass:[NSArray class]])
		_status = [((NSArray *)object).firstObject isEqualToString:@"open"] ? StatusOpen : StatusClosed;
	else
		_status = StatusClosed;
}

-(id)JSONObjectForStatus
{
	return (self.status==StatusOpen)?@"open":@"closed";
}

-(id)JSONObjectForNsStatus
{
	return (self.nsStatus==NSE_StatusOpen)?@"open":@"closed";
}

-(id)JSONObjectForNsuStatus
{
	return (self.nsuStatus==NSEU_StatusOpen)?@"open":@"closed";
}

-(id)JSONObjectForNestedStatus
{
	return (self.status==StatusOpen)?@"open":@"closed";
}

+(JSONKeyMapper*)keyMapper
{
	return [[JSONKeyMapper alloc] initWithModelToJSONDictionary:@
	{
		@"status":@"statusString",
		@"nestedStatus":@"nested.status"
	}];
}

@end
