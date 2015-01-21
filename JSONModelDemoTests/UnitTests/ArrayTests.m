//
//  ArrayTests.m
//  JSONModelDemo
//
//  Created by Marin Todorov on 19/12/2012.
//  Copyright (c) 2012 Underplot ltd. All rights reserved.
//

#import "ArrayTests.h"
#import "JSONModelLib.h"
#import "ReposModel.h"

@implementation ArrayTests
{
    ReposModel* repos;
}

-(void)setUp
{
    [super setUp];
    
    NSString* filePath = [[NSBundle bundleForClass:[JSONModel class]].resourcePath stringByAppendingPathComponent:@"github-iphone.json"];
    NSString* jsonContents = [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil];
    
    XCTAssertNotNil(jsonContents, @"Can't fetch test data file contents.");
    
    NSError* err;
    repos = [[ReposModel alloc] initWithString:jsonContents error:&err];
    XCTAssertNil(err, @"%@", [err localizedDescription]);
    
    XCTAssertNotNil(repos, @"Could not load the test data file.");

}

-(void)testLoading
{
    XCTAssertTrue([repos.repositories isMemberOfClass:[JSONModelArray class]], @".properties is not a JSONModelArray");
    XCTAssertEqualObjects([[repos.repositories[0] class] description], @"GitHubRepoModel", @".properties[0] is not a GitHubRepoModel");
}

- (void)testCount
{
    XCTAssertEqualObjects(@(repos.repositories.count), @100, @"wrong count");
}

- (void)testReadArray
{
	JSONModelArray *array = [JSONModelArray new];

	XCTAssertEqualObjects(@(array.count), @0, @"wrong count");
	XCTAssertNil([array firstObject], @"first object of an empty array should be nil");
	XCTAssertNil([array lastObject], @"last object of an empty array should be nil");
	XCTAssertNil(array[0], @"read of empty array should be nil");
	XCTAssertNil(array[2], @"read of empty array should be nil");
	XCTAssertNil(array[-2], @"read of empty array should be nil");
}

-(void)testFirstObject
{
    XCTAssertEqualObjects([[repos.repositories.firstObject class] description], @"GitHubRepoModel", @"wrong class");
}

/*
 * https://github.com/icanzilb/JSONModel/pull/14
 */
-(void)testArrayReverseTransformGitHubIssue_14
{
    NSDictionary* dict = [repos toDictionary];
    XCTAssertNotNil(dict, @"Could not convert ReposModel back to an NSDictionary");
}

/*
 * https://github.com/icanzilb/JSONModel/issues/15
 */
-(void)testArrayReverseTransformGitHubIssue_15
{
    NSString* string = [repos toJSONString];
    XCTAssertNotNil(string, @"Could not convert ReposModel back to a string");
}

@end
