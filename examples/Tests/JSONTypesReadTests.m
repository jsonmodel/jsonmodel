//
//  JSONTypesReadTests.m
//  JSONModelDemo
//
//  Created by Marin Todorov on 02/12/2012.
//  Copyright (c) 2012 Underplot ltd. All rights reserved.
//

@import XCTest;

#import "JSONTypesModel.h"

@interface JSONTypesReadTests : XCTestCase
@end

@implementation JSONTypesReadTests
{
	JSONTypesModel* t;
}

-(void)setUp
{
	[super setUp];

	NSString* filePath = [[NSBundle bundleForClass:[JSONModel class]].resourcePath stringByAppendingPathComponent:@"../../jsonTypes.json"];
	NSString* jsonContents = [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil];

	XCTAssertNotNil(jsonContents, @"Can't fetch test data file contents.");

	NSError* err;
	t = [[JSONTypesModel alloc] initWithString: jsonContents error:&err];
	XCTAssertNil(err, "%@", [err localizedDescription]);
	XCTAssertNotNil(t, @"Could not load the test data file.");
}

-(void)testStandardTypes
{
	XCTAssertTrue([t.caption isKindOfClass:[NSString class]], @"caption is not NSString object");
	XCTAssertTrue([t.caption isEqualToString:@"This is a text element"], @"caption value is not 'This is a text element'");

	XCTAssertTrue([t.dynamicString isKindOfClass:[NSMutableString class]], @"caption is not NSMutableString object");
	[t.dynamicString appendString:@"!!!"];
	XCTAssertTrue([t.dynamicString isEqualToString:@"A piece of text!!!"], @"caption value is not 'A piece of text!!!'");

	XCTAssertTrue([t.year isKindOfClass:[NSNumber class]], @"year is not NSNumber object");
	XCTAssertTrue([t.year intValue]==2012, @"year value is not 2012");

	XCTAssertTrue([t.pi isKindOfClass:[NSNumber class]], @"pi is not NSNumber object");
	XCTAssertEqualWithAccuracy([t.pi floatValue], 3.14159, FLT_EPSILON, @"pi value is not 3.14159");

	XCTAssertTrue([t.list isKindOfClass:[NSArray class]], @"list failed to read");
	XCTAssertTrue([t.list[0] isEqualToString:@"111"], @"list - first obect is not \"111\"");

	XCTAssertTrue([t.dynamicList isKindOfClass:[NSArray class]], @"dynamicList failed to read");
	XCTAssertTrue([t.dynamicList[0] isEqualToString:@"12"], @"dynamicList - first obect is not \"12\"");

	XCTAssertTrue([t.dictionary isKindOfClass:[NSDictionary class]], @"dictionary failed to read");
	XCTAssertTrue([t.dictionary[@"test"] isEqualToString:@"mest"], @"dictionary key \"test\"'s value is not \"mest\"");

	XCTAssertTrue([t.dynamicDictionary isKindOfClass:[NSMutableDictionary class]], @"dynamicDictionary failed to read");
	XCTAssertTrue([t.dynamicDictionary[@"key"] isEqualToString:@"value"], @"dynamicDictionary key \"key\"'s value is not \"value\"");
	[t.dynamicDictionary setValue:@"ADDED" forKey:@"newKey"];
	XCTAssertTrue([t.dynamicDictionary[@"newKey"] isEqualToString:@"ADDED"], @"dynamicDictionary key \"newKey\"'s value is not \"ADDED\"");

	XCTAssertTrue(!t.notAvailable, @"notAvailable is not nil");
}



@end
