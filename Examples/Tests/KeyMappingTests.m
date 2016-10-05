//
//  KeyMappingTests.m
//  JSONModelDemo
//
//  Created by Marin Todorov on 19/12/2012.
//  Copyright (c) 2012 Underplot ltd. All rights reserved.
//

@import XCTest;
@import JSONModel;

#import "GitHubKeyMapRepoModel.h"
#import "GitHubKeyMapRepoModelDict.h"
#import "GitHubRepoModelForUSMapper.h"
#import "ModelForUpperCaseMapper.h"
#import "RenamedPropertyModel.h"
#import "NestedModel.h"

#pragma GCC diagnostic ignored "-Wdeprecated-declarations"

#pragma mark - TestModel class
@interface TestModel: JSONModel

@property (strong, nonatomic) NSString* text1;
@property (strong, nonatomic) NSString<Optional>* text2;

@property (strong, nonatomic) NSString<Optional>* text3;

@end

@implementation TestModel

+(JSONKeyMapper*)keyMapper
{
	return [[JSONKeyMapper alloc] initWithDictionary:@
	{
		@"texts.text1": @"text1",
		@"texts.text2.value": @"text2"
	}];
}

@end

#pragma mark - at-name property
@interface AtNameModel : JSONModel
@property (assign) int type;
@end

@implementation AtNameModel
+(JSONKeyMapper*)keyMapper
{
	return [[JSONKeyMapper alloc] initWithDictionary:@
	{
		@"@type": @"type"
	}];
}
@end

#pragma mark - global key mapper test model
@interface GlobalModel: JSONModel
@property (strong, nonatomic) NSString* name;
@end
@implementation GlobalModel
@end

#pragma mark - KeyMappingTests unit test

@interface KeyMappingTests : XCTestCase
@end

@implementation KeyMappingTests
{
	NSArray* json;
}

-(void)setUp
{
	[super setUp];

	NSString* filePath = [[NSBundle bundleForClass:[JSONModel class]].resourcePath stringByAppendingPathComponent:@"../../github-iphone.json"];
	NSData* jsonData = [NSData dataWithContentsOfFile:filePath];

	XCTAssertNotNil(jsonData, @"Can't fetch test data file contents.");

	NSError* err;
	NSDictionary* jsonDict = [NSJSONSerialization JSONObjectWithData:jsonData options:kNilOptions error:&err];
	json = jsonDict[@"repositories"];

	XCTAssertNil(err, "%@", [err localizedDescription]);
	XCTAssertNotNil(jsonData, @"Could not load the test data file.");
}

-(void)testKeyMapping
{
	NSDictionary* repo1 = json[0];
	GitHubKeyMapRepoModel* model1 = [[GitHubKeyMapRepoModel alloc] initWithDictionary:repo1 error:nil];
	XCTAssertNotNil(model1, @"Could not initialize model");
	XCTAssertNotNil(model1.__description, @"__description is nil");
	XCTAssertTrue([model1.__description isEqualToString:repo1[@"description"]], @"__description was not mapped properly");

	NSDictionary* dict = [model1 toDictionary];
	XCTAssertNotNil(dict[@"description"], @"description not exported properly");
}

-(void)testKeyMappingWithDict
{
	NSDictionary* repo1 = json[0];
	GitHubKeyMapRepoModelDict* model1 = [[GitHubKeyMapRepoModelDict alloc] initWithDictionary:repo1 error:nil];
	XCTAssertNotNil(model1, @"Could not initialize model");
	XCTAssertNotNil(model1.__description, @"__description is nil");
	XCTAssertTrue([model1.__description isEqualToString:repo1[@"description"]], @"__description was not mapped properly");

	NSDictionary* dict = [model1 toDictionary];
	XCTAssertNotNil(dict[@"description"], @"description not exported properly");
}

-(void)testUnderscoreMapper
{
	NSString* jsonString = @"{\"pushed_at\":\"2012-12-18T19:21:35-08:00\",\"created_at\":\"2012-12-18T19:21:35-08:00\",\"a_very_long_property_name\":10000, \"item_object_145\":\"TEST\", \"item_object_176_details\":\"OTHERTEST\"}";
	GitHubRepoModelForUSMapper* m = [[GitHubRepoModelForUSMapper alloc] initWithString:jsonString error:nil];
	XCTAssertNotNil(m, @"Could not initialize model from string");

	//import
	XCTAssertTrue([m.pushedAt compare:[NSDate dateWithTimeIntervalSinceReferenceDate:0] ]==NSOrderedDescending, @"pushedAt is not initialized");
	XCTAssertTrue([m.createdAt compare:[NSDate dateWithTimeIntervalSinceReferenceDate:0] ]==NSOrderedDescending, @"createdAt is not initialized");
	XCTAssertTrue(m.aVeryLongPropertyName == 10000, @"aVeryLongPropertyName is not 10000");

	XCTAssertEqualObjects(m.itemObject145, @"TEST", @"itemObject145 does not equal 'TEST'");
	XCTAssertEqualObjects(m.itemObject176Details, @"OTHERTEST", @"itemObject176Details does not equal 'OTHERTEST'");

	//export
	NSDictionary* dict = [m toDictionary];
	XCTAssertNotNil(dict, @"toDictionary failed");

	XCTAssertNotNil(dict[@"pushed_at"], @"pushed_at not exported");
	XCTAssertNotNil(dict[@"created_at"], @"pushed_at not exported");
	XCTAssertTrue([dict[@"a_very_long_property_name"] intValue]==10000,@"a_very_long_property_name not exported properly");

	XCTAssertEqualObjects(dict[@"item_object_145"], m.itemObject145, @"item_object_145 does not equal 'TEST'");
	XCTAssertEqualObjects(dict[@"item_object_176_details"], m.itemObject176Details, @"item_object_176_details does not equal 'OTHERTEST'");
}

-(void)testUpperCaseMapper
{
	NSString* jsonString = @"{\"UPPERTEST\":\"TEST\"}";
	ModelForUpperCaseMapper * m = [[ModelForUpperCaseMapper alloc] initWithString:jsonString error:nil];
	XCTAssertNotNil(m, @"Could not initialize model from string");

	//import
	XCTAssertEqualObjects(m.uppertest, @"TEST", @"uppertest does not equal 'TEST'");

	//export
	NSDictionary* dict = [m toDictionary];
	XCTAssertNotNil(dict, @"toDictionary failed");

	XCTAssertEqualObjects(dict[@"UPPERTEST"], m.uppertest, @"UPPERTEST does not equal 'TEST'");
}

-(void)testKeyMapperCaching
{
	//simulate fetching different models, so the keyMapper cache is used

	[self testUnderscoreMapper];
	[self testKeyMapping];
	[self testUnderscoreMapper];
	[self testKeyMapping];
	[self testUnderscoreMapper];
	[self testKeyMapping];
}

-(void)testKeyPathKeyMapping
{
	//input dictionary for TestModel
	NSDictionary* dict = @
	{
		@"texts": @
		{
			@"text1": @"TEST!!!",
			@"text2": @{@"value":@"MEST"}
		}
	};

	NSError* err = nil;
	TestModel* model = [[TestModel alloc] initWithDictionary:dict error:&err];

	XCTAssertTrue(err==nil, @"Error creating TestModel: %@", [err localizedDescription]);
	XCTAssertTrue(model!=nil, @"TestModel instance is nil");

	XCTAssertTrue([model.text1 isEqualToString:@"TEST!!!"], @"text1 is not 'TEST!!!'");
	XCTAssertTrue([model.text2 isEqualToString:@"MEST"], @"text1 is not 'MEST'");

	NSDictionary* toDict = [model toDictionary];

	XCTAssertTrue([toDict[@"texts"][@"text1"] isEqualToString:@"TEST!!!"], @"toDict.texts.text1 is not 'TEST!!!'");
	XCTAssertTrue([toDict[@"texts"][@"text2"][@"value"] isEqualToString:@"MEST"], @"toDict.texts.text2.value is not 'MEST'");

	NSString* toString = [model toJSONString];
	XCTAssertTrue([toString rangeOfString:@"text1\":\"TEST!!!"].location!=NSNotFound, @"model did not export text1 in string");
}

-(void)testGlobalKeyMapperImportAndExport
{
	//import
	NSString* jsonString1 = @"{\"name\": \"NAME IN CAPITALS\"}";
	GlobalModel* global1 = [[GlobalModel alloc] initWithString:jsonString1 error:nil];
	XCTAssertNotNil(global1, @"model did not initialize with proper json");


	//test import via gloabl key mapper
	[JSONModel setGlobalKeyMapper:[[JSONKeyMapper alloc] initWithDictionary:@{
		@"name1":@"name"
	 }]];

	NSString* jsonString2 = @"{\"name1\": \"NAME IN CAPITALS\"}";
	GlobalModel* global2 = [[GlobalModel alloc] initWithString:jsonString2 error:nil];
	XCTAssertNotNil(global2, @"model did not initialize with proper json");

	//export
	NSDictionary* dict = [global2 toDictionary];
	XCTAssertNotNil(dict[@"name1"], @"model did not export name");
	NSString* exportedString = [global2 toJSONString];
	XCTAssertTrue([exportedString rangeOfString:@"name1\":\"NAME"].location!=NSNotFound, @"model did not export name in string");

	[JSONModel setGlobalKeyMapper:nil];

	GlobalModel* global3 = [[GlobalModel alloc] initWithString:jsonString2 error:nil];
	XCTAssertNil(global3, @"model supposed to be nil");

	[JSONModel setGlobalKeyMapper:nil];
}

//https://github.com/jsonmodel/jsonmodel/issues/132
-(void)testAtNameProperty
{
	AtNameModel* at = [[AtNameModel alloc] initWithString:@"{\"@type\":157}" error:nil];
	XCTAssertNotNil(at, @"model instance is nil");
}

-(void)testMergingData
{
	//import
	GlobalModel* global1 = [[GlobalModel alloc] init];
	XCTAssertNotNil(global1, @"model did not initialize");
	XCTAssertNil(global1.name, @"name got a value when nil expected");

	NSDictionary* data = @{@"name":@"NAME IN CAPITALS"};
	[global1 mergeFromDictionary:data useKeyMapping:NO error:nil];

	XCTAssertEqualObjects(global1.name, @"NAME IN CAPITALS", @"did not import name property");

	//test import via gloabl key mapper
	[JSONModel setGlobalKeyMapper:[[JSONKeyMapper alloc] initWithDictionary:@
	{
		@"name1":@"name"
	}]];
	GlobalModel* global2 = [[GlobalModel alloc] init];
	NSDictionary* data2 = @{@"name1":@"NAME IN CAPITALS"};
	[global2 mergeFromDictionary:data2 useKeyMapping:YES error:nil];

	XCTAssertEqualObjects(global2.name, @"NAME IN CAPITALS", @"did not import name property");

	[JSONModel setGlobalKeyMapper:nil];
}

-(void)testMergingDataWithInvalidType
{
	GlobalModel* global1 = [[GlobalModel alloc] init];
	XCTAssertNotNil(global1, @"model did not initialize");
	XCTAssertNil(global1.name, @"name got a value when nil expected");

	NSDictionary* data = @{@"name":[NSDate date]};
	BOOL glob1Success = [global1 mergeFromDictionary:data useKeyMapping:NO error:nil];

	XCTAssertNil(global1.name, @"should not be able to parse NSDate");
	XCTAssertEqual(glob1Success, NO);

	//test import via global key mapper
	[JSONModel setGlobalKeyMapper:[[JSONKeyMapper alloc] initWithDictionary:@
	{
		@"name1":@"name"
	}]];

	GlobalModel* global2 = [[GlobalModel alloc] init];
	NSDictionary* data2 = @{@"name1":[NSDate date]};
	BOOL glob2Success = [global2 mergeFromDictionary:data2 useKeyMapping:YES error:nil];

	XCTAssertNil(global2.name, @"should not be able to parse NSDate");
	XCTAssertEqual(glob2Success, NO);

	[JSONModel setGlobalKeyMapper:nil];
}

-(void)testMergingWithInvalidNestedModel
{
	NSString* filePath = [[NSBundle bundleForClass:[JSONModel class]].resourcePath stringByAppendingPathComponent:@"../../nestedDataWithArrayError.json"];
	NSString* jsonContents = [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil];
	NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:[jsonContents dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:nil];

	XCTAssertNotNil(jsonDict, @"Can't fetch test data file contents.");

	//import
	NestedModel* nested1 = [[NestedModel alloc] init];
	XCTAssertNotNil(nested1, @"model did not initialize");
	BOOL glob1Success = [nested1 mergeFromDictionary:jsonDict useKeyMapping:NO error:nil];
	XCTAssertEqual(glob1Success, NO);

	//test import via global key mapper
	[JSONModel setGlobalKeyMapper:[[JSONKeyMapper alloc] initWithDictionary:@
	{
		@"name1":@"name"
	}]];

	NestedModel* nested2 = [[NestedModel alloc] init];
	XCTAssertNotNil(nested2, @"model did not initialize");
	BOOL glob2Success = [nested2 mergeFromDictionary:jsonDict useKeyMapping:YES error:nil];
	XCTAssertEqual(glob2Success, NO);

	[JSONModel setGlobalKeyMapper:nil];
}

//https://github.com/jsonmodel/jsonmodel/issues/180
-(void)testUsingBothGlobalAndCustomMappers
{
	//input dictionary for TestModel
	NSDictionary* dict = @
	{
		@"texts": @
		{
			@"text1": @"TEST!!!",
			@"text2": @{@"value":@"MEST"},
			@"text3": @"Marin"
		}
	};

	//test import via gloabl key mapper
	[JSONModel setGlobalKeyMapper:[[JSONKeyMapper alloc] initWithDictionary:@
	{
		@"texts.text3":@"text3"
	}]];

	NSError* err = nil;
	TestModel* model = [[TestModel alloc] initWithDictionary:dict error:&err];

	XCTAssertTrue(err==nil, @"Error creating TestModel: %@", [err localizedDescription]);
	XCTAssertTrue(model!=nil, @"TestModel instance is nil");

	XCTAssertTrue([model.text3 isEqualToString:@"Marin"], @"text3 is not 'Marin'");

	NSDictionary* toDict = [model toDictionary];

	XCTAssertTrue([toDict[@"texts"][@"text3"] isEqualToString:@"Marin"], @"toDict.texts.text3 is not 'Marin'");

	NSString* toString = [model toJSONString];
	XCTAssertTrue([toString rangeOfString:@"text3\":\"Marin"].location!=NSNotFound, @"model did not export text3 in string");

	[JSONModel setGlobalKeyMapper:nil];
}

- (void)testExceptionsMapper
{
	NSString *jsonString = @"{\"ID\":\"12345\",\"PropName\":\"TEST\"}";
	RenamedPropertyModel *m = [[RenamedPropertyModel alloc] initWithString:jsonString error:nil];
	XCTAssertNotNil(m, @"Could not initialize model from string");

	// import
	XCTAssertEqualObjects(m.identifier, @"12345", @"identifier does not equal '12345'");
	XCTAssertEqualObjects(m.propName, @"TEST", @"propName does not equal 'TEST'");

	// export
	NSDictionary *dict = [m toDictionary];
	XCTAssertNotNil(dict, @"toDictionary failed");

	XCTAssertEqualObjects(dict[@"ID"], m.identifier, @"ID does not equal '12345'");
	XCTAssertEqualObjects(dict[@"PropName"], m.propName, @"PropName does not equal 'TEST'");
}

@end
