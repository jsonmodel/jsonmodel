//
//  CustomPropsTests.m
//  JSONModelDemo
//
//  Created by Marin Todorov on 02/12/2012.
//  Copyright (c) 2012 Underplot ltd. All rights reserved.
//

@import XCTest;
@import QuartzCore;

#import "CustomPropertyModel.h"

@interface CustomPropsTests : XCTestCase
@end

@implementation CustomPropsTests
{
	CustomPropertyModel* c;
}

-(void)setUp
{
	[super setUp];

	NSString* filePath = [[NSBundle bundleForClass:[JSONModel class]].resourcePath stringByAppendingPathComponent:@"../../colors.json"];
	NSString* jsonContents = [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil];

	XCTAssertNotNil(jsonContents, @"Can't fetch test data file contents.");

	NSError* err;
	c = [[CustomPropertyModel alloc] initWithString: jsonContents error:&err];
	XCTAssertNil(err, "%@", [err localizedDescription]);
	XCTAssertNotNil(c, @"Could not load the test data file.");
}

-(void)testColors
{
#ifdef __IPHONE_OS_VERSION_MAX_ALLOWED
	XCTAssertTrue([c.redColor isKindOfClass:[UIColor class]], @"redColor is not a Color instance");
	CGColorRef redColor = [UIColor redColor].CGColor;
#else
	XCTAssertTrue([c.redColor isKindOfClass:[NSColor class]], @"redColor is not a Color instance");
	CGColorRef redColor = [NSColor redColor].CGColor;
#endif

	XCTAssertTrue(CGColorEqualToColor(c.redColor.CGColor, redColor), @"redColor's value is not red color");
}


@end
