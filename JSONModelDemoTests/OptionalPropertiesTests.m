//
//  OptionalPropertiesTests.m
//  JSONModelDemo
//
//  Created by Marin Todorov on 02/12/2012.
//  Copyright (c) 2012 Underplot ltd. All rights reserved.
//

#import "OptionalPropertiesTests.h"
#import "OptionalPropModel.h"

@implementation OptionalPropertiesTests
{
    OptionalPropModel* o;
}

-(void)testPropertyPresent
{
    NSString* filePath = [[NSBundle mainBundle].resourcePath stringByAppendingPathComponent:@"withOptProp.json"];
    NSString* jsonContents = [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil];
    
    NSAssert(jsonContents, @"Can't fetch test data file contents.");
    
    @try {
        o = [[OptionalPropModel alloc] initWithString: jsonContents];
    }
    @catch (NSException* e1) {
        NSAssert1(NO, @"%@", [e1 debugDescription]);
    }
    
    NSAssert(o, @"Could not load the test data file.");
    NSAssert([o.notRequredProperty isEqualToString:@"I'm here this time!"], @"notRequredProperty' value is not 'I'm here this time!'");
}

-(void)testPropertyMissing
{
    NSString* filePath = [[NSBundle mainBundle].resourcePath stringByAppendingPathComponent:@"withoutOptProp.json"];
    NSString* jsonContents = [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil];
    
    NSAssert(jsonContents, @"Can't fetch test data file contents.");
    
    @try {
        o = [[OptionalPropModel alloc] initWithString: jsonContents];
    }
    @catch (NSException* e1) {
        NSAssert1(NO, @"%@", [e1 debugDescription]);
    }
    
    NSAssert(o, @"Could not load the test data file.");
    
    NSAssert(!o.notRequredProperty, @"notRequredProperty' is not nil");

}

@end
