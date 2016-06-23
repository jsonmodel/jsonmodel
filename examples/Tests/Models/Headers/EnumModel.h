//
//  EnumModel.h
//  JSONModelDemo_iOS
//
//  Created by Marin Todorov on 6/17/13.
//  Copyright (c) 2013 Underplot ltd. All rights reserved.
//

@import JSONModel;

//stock enum definition
typedef enum {
	StatusOpen = 1000,
	StatusClosed = 2000,
} Status;

//marco enum definition
typedef NS_ENUM(NSInteger, NSE_Status) {
	NSE_StatusOpen = 1001,
	NSE_StatusClosed = 2001,
};

//marco enum definition NSUInteger
typedef NS_ENUM(NSUInteger, NSEU_Status) {
	NSEU_StatusOpen = 1002,
	NSEU_StatusClosed = 2002,
};

@interface EnumModel : JSONModel

@property (nonatomic) Status status;
@property (nonatomic) NSE_Status nsStatus;
@property (nonatomic) NSEU_Status nsuStatus;
@property (nonatomic) Status nestedStatus;

@end
