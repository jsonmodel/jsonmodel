//
// Created by Petr Korolev on 21/02/14.
// Copyright (c) 2014 Underplot ltd. All rights reserved.
//

#import "ModelForUpperCaseMapper.h"

#pragma GCC diagnostic ignored "-Wdeprecated-declarations"

@implementation ModelForUpperCaseMapper

+(JSONKeyMapper*)keyMapper
{
	return [JSONKeyMapper mapperFromUpperCaseToLowerCase];
}

@end
