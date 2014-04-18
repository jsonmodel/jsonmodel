//
//  SpecialPropertiesTests.m
//  JSONModelDemo_iOS
//
//  Created by Marin Todorov on 4/18/14.
//  Copyright (c) 2014 Underplot ltd. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "JSONModel.h"

#pragma mark - model with block property
@interface BModel: JSONModel
@property (assign, nonatomic) int id;
@property (nonatomic, copy) void(^userLocationCompleted)();
@end

@implementation BModel
@end

#pragma mark - model with read-only properties
@interface RModel: JSONModel
@property (assign, nonatomic) int id;
@property (assign, nonatomic, readonly) int rId;
@property (strong, nonatomic, readonly) NSNumber* nId;
@end

@implementation RModel
@end

#pragma mark - test suite

@interface SpecialPropertiesTests : XCTestCase

@end

@implementation SpecialPropertiesTests

- (void)setUp
{
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

//test autoignoring block properties
- (void)testBlocks
{
    NSString* json = @"{\"id\":1}";
    BModel* bm = [[BModel alloc] initWithString:json error:nil];
    XCTAssertNotNil(bm, @"model failed to crate");
}

//test autoignoring read-only properties
- (void)testReadOnly
{
    NSString* json = @"{\"id\":1}";
    RModel* rm = [[RModel alloc] initWithString:json error:nil];
    XCTAssertNotNil(rm, @"model failed to crate");
}

@end

