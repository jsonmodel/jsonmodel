//
//  OptionalPropertiesTests.m
//  JSONModelDemo
//
//  Created by Marin Todorov on 02/12/2012.
//  Copyright (c) 2012 Underplot ltd. All rights reserved.
//

@import XCTest;

#import "OptionalPropModel.h"

@interface OptionalPropertiesTests : XCTestCase
@end

@implementation OptionalPropertiesTests
{
	OptionalPropModel* o;
}

-(void)testPropertyPresent
{
	NSString* filePath = [[NSBundle bundleForClass:[JSONModel class]].resourcePath stringByAppendingPathComponent:@"../../withOptProp.json"];
	NSString* jsonContents = [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil];

	XCTAssertNotNil(jsonContents, @"Can't fetch test data file contents.");

	NSError* err;
	o = [[OptionalPropModel alloc] initWithString: jsonContents error:&err];
	XCTAssertNil(err, "%@", [err localizedDescription]);
	XCTAssertNotNil(o, @"Could not load the test data file.");

	XCTAssertTrue([o.notRequredProperty isEqualToString:@"I'm here this time!"], @"notRequredProperty' value is not 'I'm here this time!'");
}

-(void)testPropertyMissing
{
	NSString* filePath = [[NSBundle bundleForClass:[JSONModel class]].resourcePath stringByAppendingPathComponent:@"../../withoutOptProp.json"];
	NSString* jsonContents = [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil];

	XCTAssertNotNil(jsonContents, @"Can't fetch test data file contents.");

	NSError* err;
	o = [[OptionalPropModel alloc] initWithString: jsonContents error:&err];
	XCTAssertNil(err, "%@", [err localizedDescription]);
	XCTAssertNotNil(o, @"Could not load the test data file.");

	XCTAssertTrue(!o.notRequredProperty, @"notRequredProperty' is not nil");

}

-(void)testNullValuesForOptionalProperties
{
	NSString* jsonWithNulls = @"{\"notRequredProperty\":null,\"fillerNumber\":1}";

	NSError* err;
	o = [[OptionalPropModel alloc] initWithString: jsonWithNulls error:&err];
	XCTAssertNil(err, "%@", [err localizedDescription]);
	XCTAssertNotNil(o, @"Could not initialize the model");

	XCTAssertTrue(!o.notRequredProperty, @"notRequredProperty' is not nil");

}

@end
