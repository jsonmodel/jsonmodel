//
//  CustomPropertyModel.h
//  JSONModelDemo
//
//  Created by Marin Todorov on 02/12/2012.
//  Copyright (c) 2012 Underplot ltd. All rights reserved.
//

@import JSONModel;

@interface CustomPropertyModel : JSONModel

/* custom transformer from JSONValueTransformer+UIColor.h */
#ifdef __IPHONE_OS_VERSION_MAX_ALLOWED
@property (strong, nonatomic) UIColor* redColor;
@property (strong, nonatomic) UIColor* blueColor;
#else
@property (strong, nonatomic) NSColor* redColor;
@property (strong, nonatomic) NSColor* blueColor;
#endif

@end
