//
//  KivaFeed.h
//  JSONModel_Demo
//
//  Created by Marin Todorov on 26/11/2012.
//  Copyright (c) 2012 Underplot ltd. All rights reserved.
//

#import "JSONModel.h"
#import "LoanModel.h"

@interface KivaFeed : JSONModel

@property (strong, nonatomic) NSArray<LoanModel, ConvertOnDemand>* loans;

@end