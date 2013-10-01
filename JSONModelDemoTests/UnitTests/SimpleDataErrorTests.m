//
//  SimpleDataErrorTests.m
//  JSONModelDemo
//
//  Created by Marin Todorov on 13/12/2012.
//  Copyright (c) 2012 Underplot ltd. All rights reserved.
//

#import "SimpleDataErrorTests.h"
#import "PrimitivesModel.h"
#import "NestedModel.h"
#import "CopyrightModel.h"

@implementation SimpleDataErrorTests

-(void)testMissingKeysError
{    
    NSString* filePath = [[NSBundle bundleForClass:[JSONModel class]].resourcePath stringByAppendingPathComponent:@"primitivesWithErrors.json"];
    NSString* jsonContents = [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil];
    
    STAssertNotNil(jsonContents, @"Can't fetch test data file contents.");
    
    NSError* err;
    PrimitivesModel* p = [[PrimitivesModel alloc] initWithString: jsonContents error:&err];
    STAssertNil(p, @"Model is not nil, when input is invalid");
    STAssertNotNil(err, @"No error when keys are missing.");
    
    STAssertTrue(err.code == kJSONModelErrorInvalidData, @"Wrong error for missing keys");
    NSArray* missingKeys = err.userInfo[kJSONModelMissingKeys];
    missingKeys = [missingKeys sortedArrayUsingSelector:@selector(compare:)];
    STAssertTrue(missingKeys, @"error does not have kJSONModelMissingKeys keys in user info");
    STAssertTrue([missingKeys[0] isEqualToString:@"intNumber"],@"missing field intNumber not found in missingKeys");
    STAssertTrue([missingKeys[1] isEqualToString:@"longNumber"],@"missing field longNumber not found in missingKeys");
}

-(void)testTypeMismatchErrorImages
{
    NSString* filePath = [[NSBundle bundleForClass:[JSONModel class]].resourcePath stringByAppendingPathComponent:@"nestedDataWithTypeMismatchOnImages.json"];
    NSString* jsonContents = [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil];

    STAssertNotNil(jsonContents, @"Can't fetch test data file contents.");

    NSError* err;
    NestedModel* p = [[NestedModel alloc] initWithString: jsonContents error:&err];
    STAssertNil(p, @"Model is not nil, when input is invalid");
    STAssertNotNil(err, @"No error when types mismatch.");

    STAssertTrue(err.code == kJSONModelErrorInvalidData, @"Wrong error for type mismatch");
    NSString* mismatchDescription = err.userInfo[kJSONModelTypeMismatch];
    STAssertTrue(mismatchDescription, @"error does not have kJSONModelTypeMismatch key in user info");
	STAssertTrue([mismatchDescription rangeOfString:@"'images'"].location != NSNotFound, @"error should mention that the 'images' property (expecting an Array) is mismatched.");

	// Make sure that the error is at the expected key-path
	STAssertEqualObjects(err.userInfo[kJSONModelKeyPath], @"images", @"kJSONModelKeyPath does not contain the expected path of the error.");
}

-(void)testTypeMismatchErrorImagesObject
{
    NSString* filePath = [[NSBundle bundleForClass:[JSONModel class]].resourcePath stringByAppendingPathComponent:@"nestedDataWithTypeMismatchOnImagesObject.json"];
    NSString* jsonContents = [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil];

    STAssertNotNil(jsonContents, @"Can't fetch test data file contents.");

    NSError* err;
    NestedModel* p = [[NestedModel alloc] initWithString: jsonContents error:&err];
    STAssertNil(p, @"Model is not nil, when input is invalid");
    STAssertNotNil(err, @"No error when types mismatch.");

    STAssertTrue(err.code == kJSONModelErrorInvalidData, @"Wrong error for type mismatch");
    NSString* mismatchDescription = err.userInfo[kJSONModelTypeMismatch];
    STAssertTrue(mismatchDescription, @"error does not have kJSONModelTypeMismatch key in user info");
	STAssertTrue([mismatchDescription rangeOfString:@"'imagesObject'"].location != NSNotFound, @"error should mention that the 'imagesObject' property (expecting a Dictionary) is mismatched.");

	// Make sure that the error is at the expected key-path
	STAssertEqualObjects(err.userInfo[kJSONModelKeyPath], @"imagesObject", @"kJSONModelKeyPath does not contain the expected path of the error.");
}

-(void)testBrokenJSON
{
    NSString* jsonContents = @"{[1,23,4],\"123\":123,}";

    NSError* err;
    PrimitivesModel* p = [[PrimitivesModel alloc] initWithString: jsonContents error:&err];
    STAssertNil(p, @"Model is not nil, when input is invalid");
    STAssertNotNil(err, @"No error when keys are missing.");
    
    STAssertTrue(err.code == kJSONModelErrorBadJSON, @"Wrong error for bad JSON");
}

- (NSError*)performTestErrorsInNestedModelFile:(NSString*)jsonFilename
{
    NSString* filePath = [[NSBundle bundleForClass:[JSONModel class]].resourcePath stringByAppendingPathComponent:jsonFilename];
    NSString* jsonContents = [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil];
    
    STAssertNotNil(jsonContents, @"Can't fetch test data file contents.");
    
    NSError* err = nil;
    NestedModel* n = [[NestedModel alloc] initWithString: jsonContents error:&err];
    STAssertNotNil(err, @"No error thrown when loading invalid data");
    
    STAssertNil(n, @"Model is not nil, when invalid data input");
    STAssertTrue(err.code == kJSONModelErrorInvalidData, @"Wrong error for missing keys");

	// Make sure that 'name' is listed as the missing key
	STAssertEqualObjects(err.userInfo[kJSONModelMissingKeys][0], @"name", @"'name' should be the missing key.");
	return err;
}

-(void)testErrorsInNestedModelsArray
{
	NSError* err = [self performTestErrorsInNestedModelFile:@"nestedDataWithArrayError.json"];

	// Make sure that the error is at the expected key-path
	STAssertEqualObjects(err.userInfo[kJSONModelKeyPath], @"images[1]", @"kJSONModelKeyPath does not contain the expected path of the error.");
}

-(void)testErrorsInNestedModelsDictionary
{
	NSError* err = [self performTestErrorsInNestedModelFile:@"nestedDataWithDictionaryError.json"];

	// Make sure that the error is at the expected key-path
	STAssertEqualObjects(err.userInfo[kJSONModelKeyPath], @"imagesObject.image2", @"kJSONModelKeyPath does not contain the expected path of the error.");
}

-(void)testForNilInputFromString
{
    JSONModelError* err = nil;
    
    //test for nil string input
    CopyrightModel* cpModel = [[CopyrightModel alloc] initWithString:nil
                                                               error:&err];
    cpModel=nil;
    
    STAssertTrue(err!=nil, @"No error returned when initialized with nil string");
    STAssertTrue(err.code == kJSONModelErrorNilInput, @"Wrong error for nil string input");
}

-(void)testForNilInputFromDictionary
{
    JSONModelError* err = nil;
    
    //test for nil string input
    CopyrightModel* cpModel = [[CopyrightModel alloc] initWithDictionary:nil
                                                                   error:&err];
    cpModel=nil;
    
    STAssertTrue(err!=nil, @"No error returned when initialized with nil dictionary");
    STAssertTrue(err.code == kJSONModelErrorNilInput, @"Wrong error for nil dictionary input");
}

@end
