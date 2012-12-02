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
    
    NSString* filePath = [[NSBundle mainBundle].resourcePath stringByAppendingPathComponent:@"jsonTypes.json"];
    NSString* jsonContents = [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil];
    
    NSAssert(jsonContents, @"Can't fetch test data file contents.");
    
    @try {
        t = [[JSONTypesModel alloc] initWithString: jsonContents];
    }
    @catch (NSException* e1) {
        NSAssert1(NO, @"%@", [e1 debugDescription]);
    }
    
    
    NSAssert(t, @"Could not load the test data file.");
}

-(void)testStandardTypes
{
    NSAssert([t.caption isKindOfClass:[NSString class]], @"caption is not NSString object");
    NSAssert([t.caption isEqualToString:@"This is a text element"], @"caption value is not 'This is a text element'");
    
    NSAssert([t.dynamicString isKindOfClass:[NSMutableString class]], @"caption is not NSMutableString object");
    [t.dynamicString appendString:@"!!!"];
    NSAssert([t.dynamicString isEqualToString:@"A piece of text!!!"], @"caption value is not 'A piece of text!!!'");
    
    NSAssert([t.year isKindOfClass:[NSNumber class]], @"year is not NSNumber object");
    NSAssert([t.year intValue]==2012, @"year value is not 2012");

    NSAssert([t.pi isKindOfClass:[NSNumber class]], @"pi is not NSNumber object");
    NSAssert(fabsf([t.pi floatValue]-3.14159)<FLT_EPSILON, @"pi value is not 3.14159");
    
    NSAssert([t.list isKindOfClass:[NSArray class]], @"list failed to read");
    NSAssert([t.list[0] isEqualToString:@"111"], @"list - first obect is not \"111\"");
    
    NSAssert([t.dynamicList isKindOfClass:[NSArray class]], @"dynamicList failed to read");
    NSAssert([t.dynamicList[0] isEqualToString:@"12"], @"dynamicList - first obect is not \"12\"");
    
    NSAssert([t.dictionary isKindOfClass:[NSDictionary class]], @"dictionary failed to read");
    NSAssert([t.dictionary[@"test"] isEqualToString:@"mest"], @"dictionary key \"test\"'s value is not \"mest\"");

    NSAssert([t.dynamicDictionary isKindOfClass:[NSMutableDictionary class]], @"dynamicDictionary failed to read");
    NSAssert([t.dynamicDictionary[@"key"] isEqualToString:@"value"], @"dynamicDictionary key \"key\"'s value is not \"value\"");
    [t.dynamicDictionary setValue:@"ADDED" forKey:@"newKey"];
    NSAssert([t.dynamicDictionary[@"newKey"] isEqualToString:@"ADDED"], @"dynamicDictionary key \"newKey\"'s value is not \"ADDED\"");
    
    NSAssert(t.notAvailable, @"notAvailable is not nil");
}



@end
