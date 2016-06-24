//
//  OptionalPropModel.h
//  JSONModelDemo
//
//  Created by Marin Todorov on 02/12/2012.
//  Copyright (c) 2012 Underplot ltd. All rights reserved.
//

@import JSONModel;

@interface OptionalPropModel : JSONModel

@property (assign, nonatomic) int fillerNumber;
@property (strong, nonatomic) NSString<Optional>* notRequredProperty;
@property (strong, nonatomic) NSString<Ignore>* ignoredProperty;
@property (assign, nonatomic) CGPoint notRequiredPoint;

+(BOOL)propertyIsOptional:(NSString*)propertyName;

@end
