//
// Created by Rahul Somasunderam on 9/4/14.
// Copyright (c) 2014 Underplot ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JSONModel.h"

@protocol InteractionModel;

@protocol DrugModel
@end
@interface DrugModel : JSONModel
@property NSString *brand_name;
@property NSArray<InteractionModel> *interaction_list;
@end