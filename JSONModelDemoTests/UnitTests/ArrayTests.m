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
    
    STAssertNotNil(jsonContents, @"Can't fetch test data file contents.");
    
    NSError* err;
    repos = [[ReposModel alloc] initWithString: jsonContents error:&err];
    STAssertNil(err, [err localizedDescription]);
    
    STAssertNotNil(repos, @"Could not load the test data file.");

}

-(void)testLoading
{
    STAssertTrue([repos.repositories isMemberOfClass:[JSONModelArray class]], @".properties is not a JSONModelArray");
    STAssertTrue([repos.repositories[0] isMemberOfClass:[GitHubRepoModel class]], @".properties[0] is not a GitHubRepoModel");
}

/*
 * https://github.com/icanzilb/JSONModel/pull/14
 */
-(void)testArrayReverseTransformGitHubIssue_14
{
    NSDictionary* dict = [repos toDictionary];
    STAssertNotNil(dict, @"Could not convert ReposModel back to an NSDictionary");
}

/*
 * https://github.com/icanzilb/JSONModel/issues/15
 */
-(void)testArrayReverseTransformGitHubIssue_15
{
    NSString* string = [repos toJSONString];
    STAssertNotNil(string, @"Could not convert ReposModel back to a string");
}

@end
