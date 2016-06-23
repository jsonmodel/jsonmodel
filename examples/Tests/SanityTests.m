//
//  SanityTests.m
//  Examples
//
//  Created by James Billingham on 23/06/2016.
//  Copyright © 2016 JSONModel. All rights reserved.
//

@import XCTest;
@import JSONModel;

@interface MyModel : JSONModel
@property (nonatomic) NSString *foo;
@property (nonatomic) NSInteger a;
@end

@implementation MyModel
@end

@interface SanityTests : XCTestCase
@end

@implementation SanityTests

- (void)testSanity
{
	XCTAssert(YES);
}

- (void)testJsonModel
{
	NSString *json = @"{\"foo\":\"bar\",\"a\":1}";

	NSError *error = nil;
	MyModel *obj = [[MyModel alloc] initWithString:json error:&error];

	XCTAssertNil(error);
	XCTAssertNotNil(obj);

	XCTAssertEqualObjects(obj.foo, @"bar");
	XCTAssertEqual(obj.a, 1);
}

@end
