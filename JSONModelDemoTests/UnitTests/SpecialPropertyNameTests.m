//
//  SpeicalPropertyNameTest.m
//  JSONModelDemo_OSX
//
//  Created by BB9z on 13-4-26.
//  Copyright (c) 2013年 Underplot ltd. All rights reserved.
//

#import "SpecialPropertyNameTests.h"
#import "SpecialPropertyModel.h"

@interface DescModel : JSONModel
@property (assign, nonatomic) int id;
@property (strong, nonatomic) NSString* description;
@end

@implementation DescModel
@end

@implementation SpecialPropertyNameTests

- (void)testSpecialPropertyName
{
    NSString* filePath = [[NSBundle bundleForClass:[JSONModel class]].resourcePath stringByAppendingPathComponent:@"specialPropertyName.json"];
    NSString* jsonContents = [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil];
    
    XCTAssertNotNil(jsonContents, @"Can't fetch test data file contents.");
    
    NSError* err;
    SpecialPropertyModel *p = [[SpecialPropertyModel alloc] initWithString: jsonContents error:&err];

    XCTAssertNotNil(p, @"Could not initialize model.");
    XCTAssertNil(err, "%@", [err localizedDescription]);
}

-(void)testDescriptionProperty
{
    NSString* json = @"{\"id\":10, \"description\":\"Marin\"}";
    DescModel* dm = [[DescModel alloc] initWithString:json error:nil];

    XCTAssertNotNil(dm, @"Could not initialize model.");
    XCTAssertEqualObjects(dm.description, @"Marin", @"could not initialize description proeprty");
    NSDictionary* dict = dm.toDictionary;
    XCTAssertEqualObjects(dict[@"description"], @"Marin", @"could not export description proeprty");
}

@end
