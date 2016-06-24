
//
//  SpecialValuesTests.m
//  JSONModelDemo_iOS
//
//  Created by Marin Todorov on 3/23/16.
//  Copyright © 2016 Underplot ltd. All rights reserved.
//

@import XCTest;
@import JSONModel;

//model class
@interface SpecialModel: JSONModel
@property (strong, nonatomic) NSString* name;
@end

@implementation SpecialModel
@end

//tests class
@interface SpecialValuesTests : XCTestCase
@end

@implementation SpecialValuesTests
{
	SpecialModel* _model;
}

- (void)setUp {
	[super setUp];

	NSString* jsonContents = @"{\"name\": \"FIRST_SECOND\"}";

	NSError *err;
	_model = [[SpecialModel alloc] initWithString:jsonContents error:&err];
	XCTAssertNil(err, "%@", [err localizedDescription]);
	XCTAssertNotNil(_model, @"Could not load the test data file.");
}

// tests: https://github.com/jsonmodel/jsonmodel/issues/460
- (void)testExample {
	XCTAssertTrue([_model.name isEqualToString:@"FIRST_SECOND"]);
}

-(void)tearDown {
	_model = nil;
}

@end
