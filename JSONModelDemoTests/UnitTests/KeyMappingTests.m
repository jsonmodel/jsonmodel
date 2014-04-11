//
//  KeyMappingTests.m
//  JSONModelDemo
//
//  Created by Marin Todorov on 19/12/2012.
//  Copyright (c) 2012 Underplot ltd. All rights reserved.
//

#import "KeyMappingTests.h"
#import "JSONModelLib.h"
#import "GitHubKeyMapRepoModel.h"
#import "GitHubKeyMapRepoModelDict.h"
#import "GitHubRepoModelForUSMapper.h"
#import "ModelForUpperCaseMapper.h"


#pragma mark - TestModel class
@interface TestModel: JSONModel

@property (strong, nonatomic) NSString* text1;
@property (strong, nonatomic) NSString<Optional>* text2;

@end
@implementation TestModel

+(JSONKeyMapper*)keyMapper
{
    return [[JSONKeyMapper alloc] initWithDictionary:@{
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
    return [[JSONKeyMapper alloc] initWithDictionary:@{
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

@implementation KeyMappingTests
{
    NSArray* json;
}

-(void)setUp
{
    [super setUp];
    
    NSString* filePath = [[NSBundle bundleForClass:[JSONModel class]].resourcePath stringByAppendingPathComponent:@"github-iphone.json"];
    NSData* jsonData = [NSData dataWithContentsOfFile:filePath];
    
    STAssertNotNil(jsonData, @"Can't fetch test data file contents.");
    
    NSError* err;
    NSDictionary* jsonDict = [NSJSONSerialization JSONObjectWithData:jsonData options:kNilOptions error:&err];
    json = jsonDict[@"repositories"];
    
    STAssertNil(err, [err localizedDescription]);
    STAssertNotNil(jsonData, @"Could not load the test data file.");
}

-(void)testKeyMapping
{
    NSDictionary* repo1 = json[0];
    GitHubKeyMapRepoModel* model1 = [[GitHubKeyMapRepoModel alloc] initWithDictionary:repo1 error:nil];
    STAssertNotNil(model1, @"Could not initialize model");
    STAssertNotNil(model1.__description, @"__description is nil");
    STAssertTrue([model1.__description isEqualToString:repo1[@"description"]], @"__description was not mapped properly");
    
    NSDictionary* dict = [model1 toDictionary];
    STAssertNotNil(dict[@"description"], @"description not exported properly");
}

-(void)testKeyMappingWithDict
{
    NSDictionary* repo1 = json[0];
    GitHubKeyMapRepoModelDict* model1 = [[GitHubKeyMapRepoModelDict alloc] initWithDictionary:repo1 error:nil];
    STAssertNotNil(model1, @"Could not initialize model");
    STAssertNotNil(model1.__description, @"__description is nil");
    STAssertTrue([model1.__description isEqualToString:repo1[@"description"]], @"__description was not mapped properly");

    NSDictionary* dict = [model1 toDictionary];
    STAssertNotNil(dict[@"description"], @"description not exported properly");
}

-(void)testUnderscoreMapper
{
    NSString* jsonString = @"{\"pushed_at\":\"2012-12-18T19:21:35-08:00\",\"created_at\":\"2012-12-18T19:21:35-08:00\",\"a_very_long_property_name\":10000, \"item_object_145\":\"TEST\", \"item_object_176_details\":\"OTHERTEST\"}";
    GitHubRepoModelForUSMapper* m = [[GitHubRepoModelForUSMapper alloc] initWithString:jsonString error:nil];
    STAssertNotNil(m, @"Could not initialize model from string");
    
    //import
    STAssertTrue([m.pushedAt compare:[NSDate dateWithTimeIntervalSinceReferenceDate:0] ]==NSOrderedDescending, @"pushedAt is not initialized");
    STAssertTrue([m.createdAt compare:[NSDate dateWithTimeIntervalSinceReferenceDate:0] ]==NSOrderedDescending, @"createdAt is not initialized");
    STAssertTrue(m.aVeryLongPropertyName == 10000, @"aVeryLongPropertyName is not 10000");

    STAssertEqualObjects(m.itemObject145, @"TEST", @"itemObject145 does not equal 'TEST'");
    STAssertEqualObjects(m.itemObject176Details, @"OTHERTEST", @"itemObject176Details does not equal 'OTHERTEST'");

    //export
    NSDictionary* dict = [m toDictionary];
    STAssertNotNil(dict, @"toDictionary failed");
    
    STAssertNotNil(dict[@"pushed_at"], @"pushed_at not exported");
    STAssertNotNil(dict[@"created_at"], @"pushed_at not exported");
    STAssertTrue([dict[@"a_very_long_property_name"] intValue]==10000,@"a_very_long_property_name not exported properly");
    
    STAssertEqualObjects(dict[@"item_object_145"], m.itemObject145, @"item_object_145 does not equal 'TEST'");
    STAssertEqualObjects(dict[@"item_object_176_details"], m.itemObject176Details, @"item_object_176_details does not equal 'OTHERTEST'");
}

-(void)testUpperCaseMapper
{
    NSString* jsonString = @"{\"UPPERTEST\":\"TEST\"}";
    ModelForUpperCaseMapper * m = [[ModelForUpperCaseMapper alloc] initWithString:jsonString error:nil];
    STAssertNotNil(m, @"Could not initialize model from string");

    //import
    STAssertEqualObjects(m.uppertest, @"TEST", @"uppertest does not equal 'TEST'");

    //export
    NSDictionary* dict = [m toDictionary];
    STAssertNotNil(dict, @"toDictionary failed");

    STAssertEqualObjects(dict[@"UPPERTEST"], m.uppertest, @"UPPERTEST does not equal 'TEST'");
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
    NSDictionary* dict = @{
        @"texts": @{
            @"text1": @"TEST!!!",
            @"text2": @{@"value":@"MEST"}
        }
    };
    
    NSError* err = nil;
    TestModel* model = [[TestModel alloc] initWithDictionary:dict error:&err];
    
    STAssertTrue(err==nil, @"Error creating TestModel: %@", [err localizedDescription]);
    STAssertTrue(model!=nil, @"TestModel instance is nil");
    
    STAssertTrue([model.text1 isEqualToString:@"TEST!!!"], @"text1 is not 'TEST!!!'");
    STAssertTrue([model.text2 isEqualToString:@"MEST"], @"text1 is not 'MEST'");
    
    NSDictionary* toDict = [model toDictionary];
    
    STAssertTrue([toDict[@"texts"][@"text1"] isEqualToString:@"TEST!!!"], @"toDict.texts.text1 is not 'TEST!!!'");
    STAssertTrue([toDict[@"texts"][@"text2"][@"value"] isEqualToString:@"MEST"], @"toDict.texts.text2.value is not 'MEST'");
    
    NSString* toString = [model toJSONString];
    STAssertTrue([toString rangeOfString:@"text1\":\"TEST!!!"].location!=NSNotFound, @"model did not export text1 in string");
}

-(void)testGlobalKeyMapperImportAndExport
{
    //import
    NSString* jsonString1 = @"{\"name\": \"NAME IN CAPITALS\"}";
    GlobalModel* global1 = [[GlobalModel alloc] initWithString:jsonString1
                                                         error:nil];
    STAssertNotNil(global1, @"model did not initialize with proper json");
    
    
    //test import via gloabl key mapper
    [JSONModel setGlobalKeyMapper:[[JSONKeyMapper alloc] initWithDictionary:@{
        @"name1":@"name"
     }]];
    
    NSString* jsonString2 = @"{\"name1\": \"NAME IN CAPITALS\"}";
    GlobalModel* global2 = [[GlobalModel alloc] initWithString:jsonString2
                                                         error:nil];
    STAssertNotNil(global2, @"model did not initialize with proper json");

    //export
    NSDictionary* dict = [global2 toDictionary];
    STAssertNotNil(dict[@"name1"], @"model did not export name");
    NSString* exportedString = [global2 toJSONString];
    STAssertTrue([exportedString rangeOfString:@"name1\":\"NAME"].location!=NSNotFound, @"model did not export name in string");
    
    [JSONModel setGlobalKeyMapper:nil];

    GlobalModel* global3 = [[GlobalModel alloc] initWithString:jsonString2
                                                         error:nil];
    STAssertNil(global3, @"model supposed to be nil");
}

//https://github.com/icanzilb/JSONModel/issues/132
-(void)testAtNameProperty
{
    AtNameModel* at = [[AtNameModel alloc] initWithString:@"{\"@type\":157}" error:nil];
    STAssertNotNil(at, @"model instance is nil");
}

-(void)testMergingData
{
    //import
    GlobalModel* global1 = [[GlobalModel alloc] init];
    STAssertNotNil(global1, @"model did not initialize");
    STAssertNil(global1.name, @"name got a value when nil expected");
    
    NSDictionary* data = @{@"name":@"NAME IN CAPITALS"};
    [global1 mergeFromDictionary:data useKeyMapping:NO];

    STAssertEqualObjects(global1.name, @"NAME IN CAPITALS", @"did not import name property");
    
    //test import via gloabl key mapper
    [JSONModel setGlobalKeyMapper:[[JSONKeyMapper alloc] initWithDictionary:@{
                                                                              @"name1":@"name"
                                                                              }]];
    GlobalModel* global2 = [[GlobalModel alloc] init];
    NSDictionary* data2 = @{@"name1":@"NAME IN CAPITALS"};
    [global2 mergeFromDictionary:data2 useKeyMapping:YES];
    
    STAssertEqualObjects(global2.name, @"NAME IN CAPITALS", @"did not import name property");
}

@end