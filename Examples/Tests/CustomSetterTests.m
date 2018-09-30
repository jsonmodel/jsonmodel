//
//  CustomPropsTests.m
//  JSONModelDemo
//
//  Created by Marin Todorov on 02/12/2012.
//  Copyright (c) 2012 Underplot ltd. All rights reserved.
//

@import XCTest;
@import QuartzCore;

#import "CustomSetterModel.h"

@interface CustomSetterTests : XCTestCase
@end

@implementation CustomSetterTests

-(void)testCustomSetterGood
{
	NSDictionary *goodJSON = @{@"title":@"Title", @"subtitle":@"Subtitle"};

	NSError *error = nil;
	CustomSetterModel *goodObj = [[CustomSetterModel alloc] initWithDictionary:goodJSON error:&error];

	XCTAssertNil(error);
	XCTAssertNotNil(goodObj);
	
	XCTAssertEqualObjects(goodObj.title, @"TITLE");
	XCTAssertEqualObjects(goodObj.subtitle, @"SUBTITLE");
}

-(void)testCustomSetterBad
{
	NSDictionary *goodJSON = @{@"title":@"Title", @"subtitle":@"Subtitle Long Long Long Long"};
	
	NSError *error = nil;
	CustomSetterModel *badObj = [[CustomSetterModel alloc] initWithDictionary:goodJSON error:&error];
	
	XCTAssertNotNil(badObj);
	XCTAssertNotNil(error);

	XCTAssertEqualObjects(badObj.title, @"TITLE");
	XCTAssertNil(badObj.subtitle);
	
	
	XCTAssertEqualObjects(error.domain, @"CustomSetterModelError");
	XCTAssertEqual(error.code, 1);
}


@end
