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

@implementation KeyMappingTests
{
    NSArray* json;
}

-(void)setUp
{
    [super setUp];
    
    NSString* filePath = [[NSBundle mainBundle].resourcePath stringByAppendingPathComponent:@"github-iphone.json"];
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
}

@end
