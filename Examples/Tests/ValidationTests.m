//
//  ValidationTestSuite.m
//  JSONModelDemo
//
//  Created by Marin Todorov on 17/12/2012.
//  Copyright (c) 2012 Underplot ltd. All rights reserved.
//

@import XCTest;

#import "JSONTypesModelWithValidation1.h"
#import "JSONTypesModelWithValidation2.h"

@interface ValidationTests : XCTestCase
@end

@implementation ValidationTests
{
	NSString* jsonContents;
}

-(void)setUp
{
	[super setUp];

	NSString* filePath = [[NSBundle bundleForClass:[JSONModel class]].resourcePath stringByAppendingPathComponent:@"../../jsonTypes.json"];
	jsonContents = [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil];
}

-(void)testValidData
{
	NSError* err;
	JSONTypesModelWithValidation1* val1 = [[JSONTypesModelWithValidation1 alloc] initWithString:jsonContents error:&err];
	NSAssert(val1, @"Model didn't initialize");
	NSAssert(!err, @"Model is not nil, but there's an error back from init");

}

-(void)testInvalidData
{
	NSError* err;
	JSONTypesModelWithValidation2* val2 = [[JSONTypesModelWithValidation2 alloc] initWithString:jsonContents error:&err];
	NSAssert(!val2, @"Model did initialize with wrong data");
	NSAssert(err.code == kJSONModelErrorModelIsInvalid, @"Error code is not kJSONModelErrorModelIsInvalid");

}

-(void)testBOOLValidationResult
{
	NSError* err;
	JSONTypesModelWithValidation1* val1 = [[JSONTypesModelWithValidation1 alloc] initWithString:jsonContents error:&err];
	val1.pi = @1.0;

	NSError* valError = nil;
	BOOL res = [val1 validate: &valError];

	NSAssert(res==NO, @"JSONTypesModelWithValidation1 validate failed to return false");
	NSAssert(valError!=nil, @"JSONTypesModelWithValidation1 validate failed to return an error object");

	val1.pi = @3.15;

	valError = nil;
	res = [val1 validate: &valError];

	NSAssert(res==YES, @"JSONTypesModelWithValidation1 validate failed to return true");
	NSAssert(valError==nil, @"JSONTypesModelWithValidation1 validate failed to return a nil error object");

}

@end
