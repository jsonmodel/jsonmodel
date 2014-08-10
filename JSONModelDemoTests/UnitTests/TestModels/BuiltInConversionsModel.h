//
//  BuiltInConversionsModel.h
//  JSONModelDemo
//
//  Created by Marin Todorov on 02/12/2012.
//  Copyright (c) 2012 Underplot ltd. All rights reserved.
//

#import "JSONModel.h"

@interface BuiltInConversionsModel : JSONModel

/* BOOL automatically converted from a number */
@property (assign, nonatomic) BOOL isItYesOrNo;

@property (assign, nonatomic) BOOL boolFromString;
@property (assign, nonatomic) BOOL boolFromNumber;
@property (assign, nonatomic) BOOL boolFromBoolean;

/* unordered list */
@property (strong, nonatomic) NSSet* unorderedList;

/* mutable unordered list */
@property (strong, nonatomic) NSMutableSet* dynamicUnorderedList;

/* automatically convert JSON data types */
@property (strong, nonatomic) NSString* stringFromNumber;
@property (strong, nonatomic) NSNumber* numberFromString;

/* predefined transformer */
@property (strong, nonatomic) NSDate* importantEvent;

/* URLs */
@property (strong, nonatomic) NSURL* websiteURL;

/* Time zone */
@property (strong, nonatomic) NSTimeZone *timeZone;

@end
