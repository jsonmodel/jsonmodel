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

@property (assign, nonatomic) unsigned int unsignedIntNumber;
@property (assign, nonatomic) unsigned long unsignedLongNumber;
@property (assign, nonatomic) long long longLongNumber;
@property (assign, nonatomic) unsigned long long unsignedLongLongNumber;
@property (assign, nonatomic) unsigned short unsignedShortNumber;
@property (assign, nonatomic) char charNumber;
@property (assign, nonatomic) unsigned char unsignedCharNumber;

@end
