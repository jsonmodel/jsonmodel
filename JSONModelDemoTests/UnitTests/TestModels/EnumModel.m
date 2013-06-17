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
-(id)JSONObjectForStatus
{
    return (self.status==StatusOpen)?@"open":@"closed";
}

+(JSONKeyMapper*)keyMapper
{
    return [[JSONKeyMapper alloc] initWithDictionary:@{
                @"statusString":@"status"
            }];
}

@end
