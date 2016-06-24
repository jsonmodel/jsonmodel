//
//  SpeicalPropertyNameTest.m
//  JSONModelDemo_OSX
//
//  Created by BB9z on 13-4-26.
//  Copyright (c) 2013年 Underplot ltd. All rights reserved.
//

@import XCTest;

#import "SpecialPropertyModel.h"

@interface DescModel : JSONModel
@property (assign, nonatomic) int id;
@end

@implementation DescModel
@end

@interface SpecialPropertyNameTests : XCTestCase
@end

@implementation SpecialPropertyNameTests

- (void)testSpecialPropertyName
{
	NSString* filePath = [[NSBundle bundleForClass:[JSONModel class]].resourcePath stringByAppendingPathComponent:@"../../specialPropertyName.json"];
	NSString* jsonContents = [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil];

	XCTAssertNotNil(jsonContents, @"Can't fetch test data file contents.");

	NSError* err;
	SpecialPropertyModel *p = [[SpecialPropertyModel alloc] initWithString: jsonContents error:&err];

	XCTAssertNotNil(p, @"Could not initialize model.");
	XCTAssertNil(err, "%@", [err localizedDescription]);
}

@end
