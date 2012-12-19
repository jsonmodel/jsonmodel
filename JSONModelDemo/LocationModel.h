//
//  LocationModel.h
//  JSONModel_Demo
//
//  Created by Marin Todorov on 26/11/2012.
//  Copyright (c) 2012 Underplot ltd. All rights reserved.
//

#import "JSONModel.h"

@interface LocationModel : JSONModel

@property (strong, nonatomic) NSString* countryCode;
@property (strong, nonatomic) NSString* country;

@end
