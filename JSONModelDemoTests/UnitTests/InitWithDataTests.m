//
//  InitWithDataTests.m
//  JSONModelDemo_iOS
//
//  Created by Johnykutty on 14/09/14.
//  Copyright (c) 2014 Underplot ltd. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "PrimitivesModel.h"
#import "NestedModel.h"
#import "CopyrightModel.h"

@interface InitWithDataTests : XCTestCase

@end

@implementation InitWithDataTests

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

-(void)testForNilInputFromData
{
    JSONModelError* err = nil;
    
    //test for nil string input
    CopyrightModel* cpModel = [[CopyrightModel alloc] initWithData:nil
                                                             error:&err];
    cpModel=nil;
    
    XCTAssertTrue(err!=nil, @"No error returned when initialized with nil string");
    XCTAssertTrue(err.code == kJSONModelErrorNilInput, @"Wrong error for nil string input");
}
@end
