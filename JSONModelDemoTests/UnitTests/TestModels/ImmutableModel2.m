//
//  ImmutableModel2.m
//  JSONModelDemo_OSX
//
//  Created by Vaňo Jakub on 17/07/15.
//  Copyright (c) 2015 Underplot ltd. All rights reserved.
//

#import "ImmutableModel2.h"

@implementation ImmutableModel2

- (instancetype)initWithRequired:(NSString *)required
                        optional:(NSString *)optional
                          ignore:(NSString *)ignore
{
    if (!(self = [super init])) return nil;
    
    _readonlyRequired = [required copy];
    _readonlyOptional = [optional copy];
    _readonlyIgnore   = [ignore copy];
    
    return self;
}

+(BOOL)ignoresReadonlyProperties
{
    return NO;
}

@end
