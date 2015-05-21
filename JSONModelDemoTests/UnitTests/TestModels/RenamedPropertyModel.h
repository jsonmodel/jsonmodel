//
//  RenamedPropertyModel.h
//  JSONModelDemo_iOS
//
//  Created by Scott Guelich on 5/21/15.
//  Copyright (c) 2015. All rights reserved.
//

#import "JSONModel.h"

@interface RenamedPropertyModel : JSONModel

@property (copy, nonatomic) NSString* identifier;
@property (copy, nonatomic) NSString* name;

@end
