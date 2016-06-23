//
// Created by Rahul Somasunderam on 9/4/14.
// Copyright (c) 2014 Underplot ltd. All rights reserved.
//

@import Foundation;
@import JSONModel;

@protocol InteractionModel;

@interface DrugModel : JSONModel

@property NSString *brand_name;
@property NSArray<InteractionModel> *interaction_list;

@end
