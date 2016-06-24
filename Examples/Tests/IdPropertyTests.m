//
//  IdPropertyTests.m
//  JSONModelDemo
//
//  Created by Marin Todorov on 13/12/2012.
//  Copyright (c) 2012 Underplot ltd. All rights reserved.
//

@import XCTest;

#import "PostsModel.h"
#import "PostModel.h"

@interface IdPropertyTests : XCTestCase
@end

@implementation IdPropertyTests
{
	PostsModel* posts;
}

-(void)setUp
{
	[super setUp];

	NSString* filePath = [[NSBundle bundleForClass:[JSONModel class]].resourcePath stringByAppendingPathComponent:@"../../post.json"];
	NSString* jsonContents = [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil];

	XCTAssertNotNil(jsonContents, @"Can't fetch test data file contents.");

	NSError* err;
	posts = [[PostsModel alloc] initWithString: jsonContents error:&err];
	XCTAssertTrue(!err, "%@", [err localizedDescription]);

	XCTAssertNotNil(posts, @"Could not load the test data file.");
}

-(void)testEquality
{
	NSString* filePath = [[NSBundle bundleForClass:[JSONModel class]].resourcePath stringByAppendingPathComponent:@"../../post.json"];
	NSString* jsonContents = [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil];

	PostsModel* posts1 = [[PostsModel alloc] initWithString: jsonContents error:nil];
	PostModel* post = posts.posts[0];

	XCTAssertTrue([post isEqual:posts1.posts[0]], @"Equal to another different model object");

	XCTAssertTrue([posts.posts indexOfObject: posts1.posts[1]]==1, @"NSArray searching for a model object failed" );
}

-(void)testCompareInequality
{
	PostModel* post = posts.posts[0];
	XCTAssertTrue(![post isEqual:nil], @"Equal to nil object");
	XCTAssertTrue(![post isEqual:[NSNull null]], @"Equal to NSNull object");
	XCTAssertTrue(![post isEqual:posts.posts[1]], @"Equal to another different model object");
}


@end
