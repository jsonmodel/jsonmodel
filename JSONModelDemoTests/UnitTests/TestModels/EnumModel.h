//
//  EnumModel.h
//  JSONModelDemo_iOS
//
//  Created by Marin Todorov on 6/17/13.
//  Copyright (c) 2013 Underplot ltd. All rights reserved.
//

#import "JSONModel.h"

typedef enum {
    StatusOpen = 1000,
    StatusClosed = 2000,
} Status;

@interface EnumModel : JSONModel

@property (nonatomic) Status status;

@end
