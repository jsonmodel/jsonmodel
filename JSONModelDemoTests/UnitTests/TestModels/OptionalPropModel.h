//
//  OptionalPropModel.h
//  JSONModelDemo
//
//  Created by Marin Todorov on 02/12/2012.
//  Copyright (c) 2012 Underplot ltd. All rights reserved.
//

#import "JSONModel.h"

@interface OptionalPropModel : JSONModel

/* filler property */
@property (assign, nonatomic) int fillerNumber;

/* optional property, not required in the JSON data */
@property (strong, nonatomic) NSString<Optional>* notRequredProperty;


@end
