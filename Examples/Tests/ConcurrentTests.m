//
//  ConcurrentTests.m
//  Examples
//
//  Created by robin on 9/8/16.
//  Copyright © 2016 JSONModel. All rights reserved.
//

@import JSONModel;
@import XCTest;

#import "ConcurrentReposModel.h"

@interface ConcurrentTests : XCTestCase
@property (nonatomic, strong) id jsonDict;
@end

@implementation ConcurrentTests

- (void)setUp
{
	[super setUp];

	NSString *filePath = [[NSBundle bundleForClass:[JSONModel class]].resourcePath stringByAppendingPathComponent:@"../../github-iphone.json"];
	NSData *jsonData = [NSData dataWithContentsOfFile:filePath];

	XCTAssertNotNil(jsonData, @"Can't fetch test data file contents.");

	NSError *err;
	self.jsonDict = [NSJSONSerialization JSONObjectWithData:jsonData options:kNilOptions error:&err];
}

- (void)testConcurrentMapping
{
	// Because the uncertainty of concurrency. Need multiple run to confirm the result.
	NSOperationQueue *queue = [NSOperationQueue new];
	queue.maxConcurrentOperationCount = 50;
	queue.suspended = YES;

	XCTestExpectation *expectation = [self expectationWithDescription:@"Wait for queue...."];

	__block int count = 0;

	for (int i = 0; i < 100; i++)
	{
		[queue addOperationWithBlock:^
		{
			ConcurrentReposModel *model = [[ConcurrentReposModel alloc] initWithDictionary:self.jsonDict error:nil];
#pragma unused(model)

			count++;

			if (count == 100)
				[expectation fulfill];
		}];
	}

	queue.suspended = NO;

	[self waitForExpectationsWithTimeout:30 handler:nil];
}

@end
