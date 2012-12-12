//
//  LoanModel.h
//  JSONModel_Demo
//
//  Created by Marin Todorov on 26/11/2012.
//  Copyright (c) 2012 Underplot ltd. All rights reserved.
//

#import "JSONModel.h"
#import "LocationModel.h"

@protocol LoanModel @end

@interface LoanModel : JSONModel

@property (strong, nonatomic) NSString* name;
@property (strong, nonatomic) NSString* status1;
@property (strong, nonatomic) NSString* use;

@property (strong, nonatomic) LocationModel* location;

@end