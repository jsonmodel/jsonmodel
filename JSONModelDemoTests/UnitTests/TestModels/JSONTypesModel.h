//
//  JSONTypesModel.h
//  JSONModelDemo
//
//  Created by Marin Todorov on 02/12/2012.
//  Copyright (c) 2012 Underplot ltd. All rights reserved.
//

#import "JSONModel.h"

@interface JSONTypesModel : JSONModel

/* string */
@property (strong, nonatomic) NSString* caption;

/* mutable string */
@property (strong, nonatomic) NSMutableString* dynamicString;

/* integer number */
@property (strong, nonatomic) NSNumber* year;

/* float number */
@property (strong, nonatomic) NSNumber* pi;

/* list */
@property (strong, nonatomic) NSArray* list;

/* mutable list */
@property (strong, nonatomic) NSMutableArray* dynamicList;

/* object */
@property (strong, nonatomic) NSDictionary* dictionary;

/* mutable object */
@property (strong, nonatomic) NSMutableDictionary* dynamicDictionary;

/* null */
@property (strong, nonatomic) NSString<Optional>* notAvailable;

@end
