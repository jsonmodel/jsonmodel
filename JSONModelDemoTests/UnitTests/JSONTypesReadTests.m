//
//  JSONTypesReadTests.m
//  JSONModelDemo
//
//  Created by Marin Todorov on 02/12/2012.
//  Copyright (c) 2012 Underplot ltd. All rights reserved.
//

#import "JSONTypesReadTests.h"
#import "JSONTypesModel.h"

@implementation JSONTypesReadTests
{
    JSONTypesModel* t;
}

-(void)setUp
{
    [super setUp];
    
    NSString* filePath = [[NSBundle bundleForClass:[JSONModel class]].resourcePath stringByAppendingPathComponent:@"jsonTypes.json"];
    NSString* jsonContents = [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil];
    
    STAssertNotNil(jsonContents, @"Can't fetch test data file contents.");
    
    NSError* err;
    t = [[JSONTypesModel alloc] initWithString: jsonContents error:&err];
    STAssertNil(err, [err localizedDescription]);
    STAssertNotNil(t, @"Could not load the test data file.");
}

-(void)testStandardTypes
{
    STAssertTrue([t.caption isKindOfClass:[NSString class]], @"caption is not NSString object");
    STAssertTrue([t.caption isEqualToString:@"This is a text element"], @"caption value is not 'This is a text element'");
    
    STAssertTrue([t.dynamicString isKindOfClass:[NSMutableString class]], @"caption is not NSMutableString object");
    [t.dynamicString appendString:@"!!!"];
    STAssertTrue([t.dynamicString isEqualToString:@"A piece of text!!!"], @"caption value is not 'A piece of text!!!'");
    
    STAssertTrue([t.year isKindOfClass:[NSNumber class]], @"year is not NSNumber object");
    STAssertTrue([t.year intValue]==2012, @"year value is not 2012");

    STAssertTrue([t.pi isKindOfClass:[NSNumber class]], @"pi is not NSNumber object");
    STAssertTrue(fabsf([t.pi floatValue]-3.14159)<FLT_EPSILON, @"pi value is not 3.14159");
    
    STAssertTrue([t.list isKindOfClass:[NSArray class]], @"list failed to read");
    STAssertTrue([t.list[0] isEqualToString:@"111"], @"list - first obect is not \"111\"");
    
    STAssertTrue([t.dynamicList isKindOfClass:[NSArray class]], @"dynamicList failed to read");
    STAssertTrue([t.dynamicList[0] isEqualToString:@"12"], @"dynamicList - first obect is not \"12\"");
    
    STAssertTrue([t.dictionary isKindOfClass:[NSDictionary class]], @"dictionary failed to read");
    STAssertTrue([t.dictionary[@"test"] isEqualToString:@"mest"], @"dictionary key \"test\"'s value is not \"mest\"");

    STAssertTrue([t.dynamicDictionary isKindOfClass:[NSMutableDictionary class]], @"dynamicDictionary failed to read");
    STAssertTrue([t.dynamicDictionary[@"key"] isEqualToString:@"value"], @"dynamicDictionary key \"key\"'s value is not \"value\"");
    [t.dynamicDictionary setValue:@"ADDED" forKey:@"newKey"];
    STAssertTrue([t.dynamicDictionary[@"newKey"] isEqualToString:@"ADDED"], @"dynamicDictionary key \"newKey\"'s value is not \"ADDED\"");
    
    STAssertTrue(!t.notAvailable, @"notAvailable is not nil");
}



@end
