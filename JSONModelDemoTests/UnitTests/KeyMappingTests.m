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

@implementation KeyMappingTests
{
    NSArray* json;
}

-(void)setUp
{
    [super setUp];
    
    NSString* filePath = [[NSBundle bundleForClass:[JSONModel class]].resourcePath stringByAppendingPathComponent:@"github-iphone.json"];
    NSData* jsonData = [NSData dataWithContentsOfFile:filePath];
    
    NSAssert(jsonData, @"Can't fetch test data file contents.");
    
    NSError* err;
    NSDictionary* jsonDict = [NSJSONSerialization JSONObjectWithData:jsonData options:kNilOptions error:&err];
    json = jsonDict[@"repositories"];
    
    NSAssert(!err, [err localizedDescription]);
    
    NSAssert(jsonData, @"Could not load the test data file.");
    
}

-(void)testKeyMapping
{
    NSDictionary* repo1 = json[0];
    GitHubKeyMapRepoModel* model1 = [[GitHubKeyMapRepoModel alloc] initWithDictionary:repo1 error:nil];
    NSAssert(model1, @"Could not initialize model");
    NSAssert(model1.__description, @"__description is nil");
    NSAssert([model1.__description isEqualToString:repo1[@"description"]], @"__description was not mapped properly");
    
    NSDictionary* dict = [model1 toDictionary];
    NSAssert(dict[@"description"], @"description not exported properly");
}

-(void)testKeyMappingWithDict
{
    NSDictionary* repo1 = json[0];
    GitHubKeyMapRepoModelDict* model1 = [[GitHubKeyMapRepoModelDict alloc] initWithDictionary:repo1 error:nil];
    NSAssert(model1, @"Could not initialize model");
    NSAssert(model1.__description, @"__description is nil");
    NSAssert([model1.__description isEqualToString:repo1[@"description"]], @"__description was not mapped properly");

    NSDictionary* dict = [model1 toDictionary];
    NSAssert(dict[@"description"], @"description not exported properly");
}

-(void)testUnderscoreMapper
{
    NSString* jsonString = @"{\"pushed_at\":\"2012-12-18T19:21:35-08:00\",\"created_at\":\"2012-12-18T19:21:35-08:00\",\"a_very_long_property_name\":10000}";
    GitHubRepoModelForUSMapper* m = [[GitHubRepoModelForUSMapper alloc] initWithString:jsonString error:nil];
    NSAssert(m, @"Could not initialize model from string");
    
    NSAssert([m.pushedAt compare:[NSDate dateWithTimeIntervalSinceReferenceDate:0] ]==NSOrderedDescending, @"pushedAt is not initialized");
    NSAssert([m.createdAt compare:[NSDate dateWithTimeIntervalSinceReferenceDate:0] ]==NSOrderedDescending, @"createdAt is not initialized");
    NSAssert(m.aVeryLongPropertyName == 10000, @"aVeryLongPropertyName is not 10000");
    
    //export
    NSDictionary* dict = [m toDictionary];
    NSAssert(dict, @"toDictionary failed");
    
    NSAssert(dict[@"pushed_at"], @"pushed_at not exported");
    NSAssert(dict[@"created_at"], @"pushed_at not exported");
    NSAssert([dict[@"a_very_long_property_name"] intValue]==10000,@"a_very_long_property_name not exported properly");
    
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

@end
