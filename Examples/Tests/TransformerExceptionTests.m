//
//  TransformerExceptionTests.m
//  Examples
//
//  Created by James Billingham on 12/09/2016.
//  Copyright © 2016 JSONModel. All rights reserved.
//

@import JSONModel;
@import XCTest;

@interface User : JSONModel
@property (nonatomic, strong) NSDate *birthday;
@end

@implementation User
@end

@interface TransformerExceptionTests : XCTestCase
@end

@implementation TransformerExceptionTests

- (void)testTransformerExceptions
{
	NSDictionary *goodJSON = @{@"birthday":@"1992-03-15 00:00:00.000000"};
	NSDictionary *badJSON = @{@"birthday":@{@"date":@"1992-03-15 00:00:00.000000", @"time":@123}};
	NSError *error = nil;

	User *goodObj = [[User alloc] initWithDictionary:goodJSON error:&error];
	XCTAssertNotNil(goodObj);
	XCTAssertNil(error);

	User *badObj = [[User alloc] initWithDictionary:badJSON error:&error];
	XCTAssertNil(badObj);
	XCTAssertNotNil(error);
}

@end
