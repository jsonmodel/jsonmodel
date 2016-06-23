//
// Created by Rahul Somasunderam on 9/4/14.
// Copyright (c) 2014 Underplot ltd. All rights reserved.
//

@import Foundation;
@import JSONModel;

@protocol DrugModel;

@interface ExtremeNestingModel : JSONModel

@property NSArray<DrugModel> *drugs;

@end
