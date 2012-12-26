//
//  MyDataModel.h
//  JSONModelDemo
//
//  Created by Marin Todorov on 02/12/2012.
//  Copyright (c) 2012 Underplot ltd. All rights reserved.
//

#import "JSONModel.h"

@interface MyDataModel : JSONModel

@property (strong, nonatomic) NSString* content;
@property (assign, nonatomic) int timesSaved;

@end
