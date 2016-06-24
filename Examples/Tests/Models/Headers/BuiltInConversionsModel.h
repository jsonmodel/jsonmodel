//
//  BuiltInConversionsModel.h
//  JSONModelDemo
//
//  Created by Marin Todorov on 02/12/2012.
//  Copyright (c) 2012 Underplot ltd. All rights reserved.
//

@import JSONModel;

@interface BuiltInConversionsModel : JSONModel

/* BOOL automatically converted from a number */
@property (assign, nonatomic) BOOL isItYesOrNo;

@property (assign, nonatomic) BOOL boolFromString;
@property (assign, nonatomic) BOOL boolFromNumber;
@property (assign, nonatomic) BOOL boolFromBoolean;

@property (strong, nonatomic) NSSet* unorderedList;
@property (strong, nonatomic) NSMutableSet* dynamicUnorderedList;

/* automatically convert JSON data types */
@property (strong, nonatomic) NSString* stringFromNumber;
@property (strong, nonatomic) NSNumber* numberFromString;
@property (strong, nonatomic) NSNumber* doubleFromString;

@property (strong, nonatomic) NSDate* importantEvent;
@property (strong, nonatomic) NSURL* websiteURL;
@property (strong, nonatomic) NSTimeZone *timeZone;
@property (strong, nonatomic) NSArray* stringArray;

@end
