//
//  PrimitivesModel.h
//  JSONModelDemo
//
//  Created by Marin Todorov on 02/12/2012.
//  Copyright (c) 2012 Underplot ltd. All rights reserved.
//

#import "JSONModel.h"

@interface PrimitivesModel : JSONModel

/* short type */
@property (assign, nonatomic) short shortNumber;

/* int type */
@property (assign, nonatomic) int intNumber;

/* long type */
@property (assign, nonatomic) long longNumber;

/* float type */
@property (assign, nonatomic) float floatNumber;

/* double type */
@property (assign, nonatomic) double doubleNumber;

/* BOOL */
@property (assign, nonatomic) BOOL boolYES;

/* BOOL */
@property (assign, nonatomic) BOOL boolNO;

@end
