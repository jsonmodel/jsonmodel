//
//  JSONTypesModel.h
//  JSONModelDemo
//
//  Created by Marin Todorov on 02/12/2012.
//  Copyright (c) 2012 Underplot ltd. All rights reserved.
//

@import JSONModel;

@interface JSONTypesModel : JSONModel

@property (strong, nonatomic) NSString* caption;
@property (strong, nonatomic) NSMutableString* dynamicString;
@property (strong, nonatomic) NSNumber* year;
@property (strong, nonatomic) NSNumber* pi;
@property (strong, nonatomic) NSArray* list;
@property (strong, nonatomic) NSMutableArray* dynamicList;
@property (strong, nonatomic) NSDictionary* dictionary;
@property (strong, nonatomic) NSMutableDictionary* dynamicDictionary;
@property (strong, nonatomic) NSString<Optional>* notAvailable;

@end
