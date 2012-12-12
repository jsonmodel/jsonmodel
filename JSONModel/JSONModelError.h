//
//  JSONModelErrors.h
//  JSONModelDemo
//
//  Created by Marin Todorov on 12/12/2012.
//  Copyright (c) 2012 Underplot ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

enum kJSONModelErrorTypes
{
    kJSONModelErrorInvalidData = 1,
    kJSONModelErrorBadResponse = 2
};

extern NSString * const JSONModelErrorDomain;

@interface JSONModelError : NSError

@property (assign, nonatomic) int type;

+(id)errorInvalidData;
+(id)errorBadResponse;

@end


