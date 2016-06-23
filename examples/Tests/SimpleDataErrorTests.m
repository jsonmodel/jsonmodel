//
//  SimpleDataErrorTests.m
//  JSONModelDemo
//
//  Created by Marin Todorov on 13/12/2012.
//  Copyright (c) 2012 Underplot ltd. All rights reserved.
//

@import XCTest;

#import "PrimitivesModel.h"
#import "NestedModel.h"
#import "CopyrightModel.h"

@interface SimpleDataErrorTests : XCTestCase
@end

@implementation SimpleDataErrorTests

-(void)testMissingKeysError
{
	NSString* filePath = [[NSBundle bundleForClass:[JSONModel class]].resourcePath stringByAppendingPathComponent:@"../../primitivesWithErrors.json"];
	NSString* jsonContents = [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil];

	XCTAssertNotNil(jsonContents, @"Can't fetch test data file contents.");

	NSError* err;
	PrimitivesModel* p = [[PrimitivesModel alloc] initWithString: jsonContents error:&err];
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
	NSString* jsonContents = [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil];

	XCTAssertNotNil(jsonContents, @"Can't fetch test data file contents.");

	NSError* err = nil;
	NestedModel* p = [[NestedModel alloc] initWithString: jsonContents error:&err];
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
	NSString* jsonContents = [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil];

	XCTAssertNotNil(jsonContents, @"Can't fetch test data file contents.");

	NSError* err;
	NestedModel* p = [[NestedModel alloc] initWithString: jsonContents error:&err];
	XCTAssertNil(p, @"Model is not nil, when input is invalid");
	XCTAssertNotNil(err, @"No error when types mismatch.");

	XCTAssertTrue(err.code == kJSONModelErrorInvalidData, @"Wrong error for type mismatch");
	NSString* mismatchDescription = err.userInfo[kJSONModelTypeMismatch];
	XCTAssertTrue(mismatchDescription, @"error does not have kJSONModelTypeMismatch key in user info");
	XCTAssertTrue([mismatchDescription rangeOfString:@"'imagesObject'"].location != NSNotFound, @"error should mention that the 'imagesObject' property (expecting a Dictionary) is mismatched.");

	// Make sure that the error is at the expected key-path
	XCTAssertEqualObjects(err.userInfo[kJSONModelKeyPath], @"imagesObject", @"kJSONModelKeyPath does not contain the expected path of the error.");
}

-(void)testBrokenJSON
{
	NSString* jsonContents = @"{[1,23,4],\"123\":123,}";

	NSError* err;
	PrimitivesModel* p = [[PrimitivesModel alloc] initWithString: jsonContents error:&err];
	XCTAssertNil(p, @"Model is not nil, when input is invalid");
	XCTAssertNotNil(err, @"No error when keys are missing.");

	XCTAssertTrue(err.code == kJSONModelErrorBadJSON, @"Wrong error for bad JSON");
}

- (NSError*)performTestErrorsInNestedModelFile:(NSString*)jsonFilename
{
	NSString* filePath = [[NSBundle bundleForClass:[JSONModel class]].resourcePath stringByAppendingPathComponent:jsonFilename];
	NSString* jsonContents = [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil];

	XCTAssertNotNil(jsonContents, @"Can't fetch test data file contents.");

	NSError* err = nil;
	NestedModel* n = [[NestedModel alloc] initWithString: jsonContents error:&err];
	XCTAssertNotNil(err, @"No error thrown when loading invalid data");

	XCTAssertNil(n, @"Model is not nil, when invalid data input");
	XCTAssertTrue(err.code == kJSONModelErrorInvalidData, @"Wrong error for missing keys");

	// Make sure that 'name' is listed as the missing key
	XCTAssertEqualObjects(err.userInfo[kJSONModelMissingKeys][0], @"name", @"'name' should be the missing key.");
	return err;
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

-(void)testForNilInputFromString
{
	JSONModelError* err = nil;

	//test for nil string input
	CopyrightModel* cpModel = [[CopyrightModel alloc] initWithString:nil error:&err];
	cpModel=nil;

	XCTAssertTrue(err!=nil, @"No error returned when initialized with nil string");
	XCTAssertTrue(err.code == kJSONModelErrorNilInput, @"Wrong error for nil string input");
}

-(void)testForNilInputFromDictionary
{
	JSONModelError* err = nil;

	//test for nil string input
	CopyrightModel* cpModel = [[CopyrightModel alloc] initWithDictionary:nil error:&err];
	cpModel=nil;

	XCTAssertTrue(err!=nil, @"No error returned when initialized with nil dictionary");
	XCTAssertTrue(err.code == kJSONModelErrorNilInput, @"Wrong error for nil dictionary input");
}

-(void)testForNullValuesForRequiredProperty
{
	JSONModelError* err = nil;
	NSString* jsonString = @"{\"author\":\"Marin\",\"year\":null}";

	CopyrightModel* cpModel = [[CopyrightModel alloc] initWithString:jsonString error:&err];
	cpModel = nil;
	XCTAssertTrue(err, @"No error returned when initialized with nil dictionary");
	XCTAssertTrue(err.code == kJSONModelErrorInvalidData, @"Wrong error null value for a required property");
}

@end
