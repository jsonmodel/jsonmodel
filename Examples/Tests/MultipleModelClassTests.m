//
//  MultipleModelClassTests.m
//  Examples
//
//  Created by Seamus on 2018/3/1.
//  Copyright © 2018年 JSONModel. All rights reserved.
//

@import JSONModel;
@import XCTest;
#import "MultipleModel.h"

@interface MultipleModelClassTests : XCTestCase
@property (nonatomic, strong) id jsonArray;
@property (nonatomic, strong) NSArray * modelArray;
@end

@implementation MultipleModelClassTests


- (void)setUp {
    [super setUp];
    
	NSString *filePath = [[NSBundle bundleForClass:[JSONModel class]].resourcePath stringByAppendingPathComponent:@"../../multipleTypes.json"];
	NSData *jsonData = [NSData dataWithContentsOfFile:filePath];
	
	XCTAssertNotNil(jsonData, @"Can't fetch test data file contents.");
	
	NSError *err;
	self.jsonArray = [NSJSONSerialization JSONObjectWithData:jsonData options:kNilOptions error:&err];
	
	NSError *error;
	NSArray *array = [MultipleModel arrayOfModelsFromDictionaries:self.jsonArray error:&error];
	self.modelArray = array;
	XCTAssertNil(error, @"%@", [error localizedDescription]);
}

-(void)testCount
{
	XCTAssertEqualObjects(@(self.modelArray.count), @2, @"wrong count");
}

-(void)testFastEnumeration
{
	XCTAssertEqualObjects([[self.modelArray.firstObject class] description], @"MultiplePicModel", @"wrong class");
	
	XCTAssertEqualObjects([[self.modelArray.lastObject class] description], @"MultipleCarModel", @"wrong class");
}

@end
