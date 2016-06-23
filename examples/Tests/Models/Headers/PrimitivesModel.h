//
//  PrimitivesModel.h
//  JSONModelDemo
//
//  Created by Marin Todorov on 02/12/2012.
//  Copyright (c) 2012 Underplot ltd. All rights reserved.
//

@import JSONModel;

@interface PrimitivesModel : JSONModel

@property (assign, nonatomic) short shortNumber;
@property (assign, nonatomic) int intNumber;
@property (assign, nonatomic) long longNumber;
@property (assign, nonatomic) float floatNumber;
@property (assign, nonatomic) double doubleNumber;
@property (assign, nonatomic) BOOL boolYES;
@property (assign, nonatomic) BOOL boolNO;

@end
