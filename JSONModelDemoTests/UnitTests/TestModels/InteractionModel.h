//
// Created by Rahul Somasunderam on 9/4/14.
// Copyright (c) 2014 Underplot ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JSONModel.h"

@protocol InteractionModel
@end
@interface InteractionModel : JSONModel
@property NSString *type;
@property NSString *title;
@end