//
//  RenamedPropertyModel.h
//  JSONModelDemo_iOS
//
//  Created by James Billingham on 16/12/2015.
//  Copyright © 2015 Underplot ltd. All rights reserved.
//

@import JSONModel;

@interface RenamedPropertyModel : JSONModel

@property (copy, nonatomic) NSString *identifier;
@property (copy, nonatomic) NSString *propName;

@end
