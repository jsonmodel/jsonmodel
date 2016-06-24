//
//  InitWithDataTests.m
//  JSONModelDemo_iOS
//
//  Created by Johnykutty on 14/09/14.
//  Copyright (c) 2014 Underplot ltd. All rights reserved.
//

@import XCTest;

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
	CopyrightModel* cpModel = [[CopyrightModel alloc] initWithData:nil error:&err];
	cpModel=nil;

	XCTAssertTrue(err!=nil, @"No error returned when initialized with nil string");
	XCTAssertTrue(err.code == kJSONModelErrorNilInput, @"Wrong error for nil string input");
}

-(void)testErrorsInNestedModelsArray
{
	NSError* err = [self performTestErrorsInNestedModelFile:@"../../nestedDataWithArrayError.json"];

	// Make sure that the error is at the expected key-path
	XCTAssertEqualObjects(err.userInfo[kJSONModelKeyPath], @"images[1]", @"kJSONModelKeyPath does not contain the expected path of the error.");
}

-(void)testErrorsInNestedModelsDictionary
{
	NSError* err = [self performTestErrorsInNestedModelFile:@"../../nestedDataWithDictionaryError.json"];

	// Make sure that the error is at the expected key-path
	XCTAssertEqualObjects(err.userInfo[kJSONModelKeyPath], @"imagesObject.image2", @"kJSONModelKeyPath does not contain the expected path of the error.");
}

- (NSError*)performTestErrorsInNestedModelFile:(NSString*)jsonFilename
{
	NSString* filePath = [[NSBundle bundleForClass:[JSONModel class]].resourcePath stringByAppendingPathComponent:jsonFilename];
	NSData *jsonData = [NSData dataWithContentsOfFile:filePath];

	XCTAssertNotNil(jsonData, @"Can't fetch test data file contents.");

	NSError* err = nil;
	NestedModel* n = [[NestedModel alloc] initWithData: jsonData error:&err];
	XCTAssertNotNil(err, @"No error thrown when loading invalid data");

	XCTAssertNil(n, @"Model is not nil, when invalid data input");
	XCTAssertTrue(err.code == kJSONModelErrorInvalidData, @"Wrong error for missing keys");

	// Make sure that 'name' is listed as the missing key
	XCTAssertEqualObjects(err.userInfo[kJSONModelMissingKeys][0], @"name", @"'name' should be the missing key.");
	return err;
}

-(void)testMissingKeysError
{
	NSString* filePath = [[NSBundle bundleForClass:[JSONModel class]].resourcePath stringByAppendingPathComponent:@"../../primitivesWithErrors.json"];
	NSData *jsonData = [NSData dataWithContentsOfFile:filePath];

	XCTAssertNotNil(jsonData, @"Can't fetch test data file contents.");

	NSError* err;
	PrimitivesModel* p = [[PrimitivesModel alloc] initWithData: jsonData error:&err];
	XCTAssertNil(p, @"Model is not nil, when input is invalid");
	XCTAssertNotNil(err, @"No error when keys are missing.");

	XCTAssertTrue(err.code == kJSONModelErrorInvalidData, @"Wrong error for missing keys");
	NSArray* missingKeys = err.userInfo[kJSONModelMissingKeys];
	missingKeys = [missingKeys sortedArrayUsingSelector:@selector(compare:)];
	XCTAssertTrue(missingKeys, @"error does not have kJSONModelMissingKeys keys in user info");
	XCTAssertTrue([missingKeys[0] isEqualToString:@"intNumber"],@"missing field intNumber not found in missingKeys");
	XCTAssertTrue([missingKeys[1] isEqualToString:@"longNumber"],@"missing field longNumber not found in missingKeys");
}

-(void)testTypeMismatchErrorImages
{
	NSString* filePath = [[NSBundle bundleForClass:[JSONModel class]].resourcePath stringByAppendingPathComponent:@"../../nestedDataWithTypeMismatchOnImages.json"];
	NSData *jsonData = [NSData dataWithContentsOfFile:filePath];

	XCTAssertNotNil(jsonData, @"Can't fetch test data file contents.");

	NSError* err = nil;
	NestedModel* p = [[NestedModel alloc] initWithData: jsonData error:&err];
	XCTAssertNil(p, @"Model is not nil, when input is invalid");
	XCTAssertNotNil(err, @"No error when types mismatch.");

	XCTAssertTrue(err.code == kJSONModelErrorInvalidData, @"Wrong error for type mismatch");
	NSString* mismatchDescription = err.userInfo[kJSONModelTypeMismatch];
	XCTAssertTrue(mismatchDescription, @"error does not have kJSONModelTypeMismatch key in user info");
	XCTAssertTrue([mismatchDescription rangeOfString:@"'images'"].location != NSNotFound, @"error should mention that the 'images' property (expecting an Array) is mismatched.");

	// Make sure that the error is at the expected key-path
	XCTAssertEqualObjects(err.userInfo[kJSONModelKeyPath], @"images", @"kJSONModelKeyPath does not contain the expected path of the error.");
}

-(void)testTypeMismatchErrorImagesObject
{
	NSString* filePath = [[NSBundle bundleForClass:[JSONModel class]].resourcePath stringByAppendingPathComponent:@"../../nestedDataWithTypeMismatchOnImagesObject.json"];
	NSData *jsonData = [NSData dataWithContentsOfFile:filePath];

	XCTAssertNotNil(jsonData, @"Can't fetch test data file contents.");

	NSError* err;
	NestedModel* p = [[NestedModel alloc] initWithData: jsonData error:&err];
	XCTAssertNil(p, @"Model is not nil, when input is invalid");
	XCTAssertNotNil(err, @"No error when types mismatch.");

	XCTAssertTrue(err.code == kJSONModelErrorInvalidData, @"Wrong error for type mismatch");
	NSString* mismatchDescription = err.userInfo[kJSONModelTypeMismatch];
	XCTAssertTrue(mismatchDescription, @"error does not have kJSONModelTypeMismatch key in user info");
	XCTAssertTrue([mismatchDescription rangeOfString:@"'imagesObject'"].location != NSNotFound, @"error should mention that the 'imagesObject' property (expecting a Dictionary) is mismatched.");

	// Make sure that the error is at the expected key-path
	XCTAssertEqualObjects(err.userInfo[kJSONModelKeyPath], @"imagesObject", @"kJSONModelKeyPath does not contain the expected path of the error.");
}

@end
