//
//  ArrayTests.m
//  JSONModelDemo
//
//  Created by Marin Todorov on 19/12/2012.
//  Copyright (c) 2012 Underplot ltd. All rights reserved.
//

@import XCTest;
@import JSONModel;

#import "ReposModel.h"
#import "GitHubRepoModel.h"

@interface ArrayTests : XCTestCase
@end

@implementation ArrayTests
{
	ReposModel* repos;
	ReposProtocolArrayModel* reposProtocolArray;
}

-(void)setUp
{
	[super setUp];

	NSString* filePath = [[NSBundle bundleForClass:[JSONModel class]].resourcePath stringByAppendingPathComponent:@"../../github-iphone.json"];
	NSString* jsonContents = [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil];

	XCTAssertNotNil(jsonContents, @"Can't fetch test data file contents.");

	NSError* err;
	repos = [[ReposModel alloc] initWithString:jsonContents error:&err];
	XCTAssertNil(err, @"%@", [err localizedDescription]);

	reposProtocolArray = [[ReposProtocolArrayModel alloc] initWithString:jsonContents error:&err];
	XCTAssertNil(err, @"%@", [err localizedDescription]);

	XCTAssertNotNil(repos, @"Could not load the test data file.");

}

-(void)testLoading
{
	XCTAssertTrue([repos.repositories isKindOfClass:[NSArray class]], @".properties is not a NSArray");
	XCTAssertEqualObjects([[repos.repositories[0] class] description], @"GitHubRepoModel", @".properties[0] is not a GitHubRepoModel");

	XCTAssertTrue([reposProtocolArray.repositories isKindOfClass:[NSArray class]], @".properties is not a NSArray");
	XCTAssertEqualObjects([[reposProtocolArray.repositories[0] class] description], @"GitHubRepoModel", @".properties[0] is not a GitHubRepoModel");
}

-(void)testCount
{
	XCTAssertEqualObjects(@(repos.repositories.count), @100, @"wrong count");
	XCTAssertEqualObjects(@(reposProtocolArray.repositories.count), @100, @"wrong count");
}

-(void)testFastEnumeration
{
	for (GitHubRepoModel *m in repos.repositories) {
		XCTAssertNoThrow([m created], @"should not throw exception");
	}

	for (GitHubRepoModel *m in reposProtocolArray.repositories) {
		XCTAssertNoThrow([m created], @"should not throw exception");
	}
}

-(void)testFirstObject
{
	XCTAssertEqualObjects([[repos.repositories.firstObject class] description], @"GitHubRepoModel", @"wrong class");
	XCTAssertEqualObjects([[reposProtocolArray.repositories.firstObject class] description], @"GitHubRepoModel", @"wrong class");
}

/*
 * https://github.com/jsonmodel/jsonmodel/pull/14
 */
-(void)testArrayReverseTransformGitHubIssue_14
{
	NSDictionary* dict = [repos toDictionary];
	XCTAssertNotNil(dict, @"Could not convert ReposModel back to an NSDictionary");

	NSDictionary* dict2 = [reposProtocolArray toDictionary];
	XCTAssertNotNil(dict2, @"Could not convert ReposProtocolArrayModel back to an NSDictionary");
}

/*
 * https://github.com/jsonmodel/jsonmodel/issues/15
 */
-(void)testArrayReverseTransformGitHubIssue_15
{
	NSString* string = [repos toJSONString];
	XCTAssertNotNil(string, @"Could not convert ReposModel back to a string");

	NSString* string2 = [reposProtocolArray toJSONString];
	XCTAssertNotNil(string2, @"Could not convert ReposProtocolArrayModel back to a string");
}

@end
