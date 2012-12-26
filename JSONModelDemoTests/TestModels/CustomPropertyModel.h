//
//  CustomPropertyModel.h
//  JSONModelDemo
//
//  Created by Marin Todorov on 02/12/2012.
//  Copyright (c) 2012 Underplot ltd. All rights reserved.
//

#import "JSONModel.h"

//TODO: The methods the category adds are accessible without importing the header, what gives?
#import "JSONValueTransformer+UIColor.h"

@interface CustomPropertyModel : JSONModel

/* custom transformer from JSONValueTransformer+UIColor.h */
@property (strong, nonatomic) Color* redColor;
@property (strong, nonatomic) Color* blueColor;


@end
