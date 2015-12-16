//
//  RenamedPropertyModel.m
//  JSONModelDemo_iOS
//
//  Created by Scott Guelich on 5/21/15.
//  Copyright (c) 2015. All rights reserved.
//

#import "RenamedPropertyModel.h"

@implementation RenamedPropertyModel

+ (JSONKeyMapper *)keyMapper {
    return [JSONKeyMapper mapper:[JSONKeyMapper mapperFromUpperCaseToLowerCase]
                  withExceptions:@{@"ID": @"identifier"}];
}

@end
