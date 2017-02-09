//
//  JSONModelCustomSetter.m
//  JSONModel
//
//  Created by Dmytro Povolotskyi on 09/02/2017.
//  Copyright © 2017 com.jsonmodel. All rights reserved.
//

#import "JSONModelCustomSetter.h"

@implementation JSONModelCustomSetter

- (instancetype)initWithValue:(NSValue*)value withErrorOutParam:(BOOL) withErrorOutParam
{
    self = [super init];
    if (self) {
        _value = value;
        _withErrorOutParam = withErrorOutParam;
    }
    return self;
}

@end
