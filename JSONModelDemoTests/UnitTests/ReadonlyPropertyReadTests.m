//
//  ReadonlyPropertyTests.m
//  JSONModelDemo_OSX
//
//  Created by Vaňo Jakub on 15/07/15.
//  Copyright (c) 2015 Underplot ltd. All rights reserved.
//

#import "ReadonlyPropertyReadTests.h"
#import "ImmutableModel.h"

@implementation ReadonlyPropertyReadTests
{
    ImmutableModel* i;
}

- (void) testAllPropertiesPresent
{
    NSString* filePath = [[NSBundle bundleForClass:[JSONModel class]].resourcePath stringByAppendingPathComponent:@"allPropsPresent.json"];
    NSString* jsonContents = [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil];
    
    XCTAssertNotNil(jsonContents, @"Can't fetch test data file contents.");
    
    NSError* err;
    i = [[ImmutableModel alloc] initWithString:jsonContents error:&err];
    XCTAssertNil(err, "%@", [err localizedDescription]);
    XCTAssertNotNil(i, @"Could not load the test data file.");
    
    XCTAssertTrue([i.readonlyRequired isEqualToString:@"I'm here!"], @"readonlyRequired' value is not 'I'm here!'");
    XCTAssertTrue([i.readonlyOptional isEqualToString:@"I'm here!"], @"readonlyOptional' value is not 'I'm here!'");
    XCTAssertNil(i.readonlyIgnore, @"readonlyIgnore' value is not nil");
}

- (void) testRequiredPropertyMissing
{
    NSString* filePath = [[NSBundle bundleForClass:[JSONModel class]].resourcePath stringByAppendingPathComponent:@"requiredPropMissing.json"];
    NSString* jsonContents = [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil];
    
    XCTAssertNotNil(jsonContents, @"Can't fetch test data file contents.");
    
    NSError* err;
    i = [[ImmutableModel alloc] initWithString:jsonContents error:&err];
    XCTAssertNotNil(err, "Initialising with string missing required proiperty did not produce error");
    XCTAssertNil(i, "Object was succesfully initialised with missing property");
}

- (void) testOptionalPropertyMissing
{
    NSString* filePath = [[NSBundle bundleForClass:[JSONModel class]].resourcePath stringByAppendingPathComponent:@"optionalPropMissing.json"];
    NSString* jsonContents = [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil];
    
    XCTAssertNotNil(jsonContents, @"Can't fetch test data file contents.");
    
    NSError* err;
    i = [[ImmutableModel alloc] initWithString:jsonContents error:&err];
    XCTAssertNil(err, "%@", [err localizedDescription]);
    XCTAssertNotNil(i, @"Could not load the test data file.");
    
    XCTAssertTrue([i.readonlyRequired isEqualToString:@"I'm here!"], @"readonlyRequired' value is not 'I'm here!'");
    XCTAssertNil(i.readonlyOptional, @"readonlyOptional' value is not nil");
    XCTAssertNil(i.readonlyIgnore, @"readonlyIgnore' value is not nil");
}

- (void) testIgnorePropertyMissing
{
    NSString* filePath = [[NSBundle bundleForClass:[JSONModel class]].resourcePath stringByAppendingPathComponent:@"ignorePropMissing.json"];
    NSString* jsonContents = [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil];
    
    XCTAssertNotNil(jsonContents, @"Can't fetch test data file contents.");
    
    NSError* err;
    i = [[ImmutableModel alloc] initWithString:jsonContents error:&err];
    XCTAssertNil(err, "%@", [err localizedDescription]);
    XCTAssertNotNil(i, @"Could not load the test data file.");
    
    XCTAssertTrue([i.readonlyRequired isEqualToString:@"I'm here!"], @"readonlyRequired' value is not 'I'm here!'");
    XCTAssertTrue([i.readonlyOptional isEqualToString:@"I'm here!"], @"readonlyOptional' value is not 'I'm here!'");
    XCTAssertNil(i.readonlyIgnore, @"readonlyIgnore' value is not nil");
}

@end
