//
//  BuiltInConversionsTests.m
//  JSONModelDemo
//
//  Created by Marin Todorov on 02/12/2012.
//  Copyright (c) 2012 Underplot ltd. All rights reserved.
//

#import "BuiltInConversionsTests.h"
#import "BuiltInConversionsModel.h"

@implementation BuiltInConversionsTests
{
    BuiltInConversionsModel* b;
}

-(void)setUp
{
    [super setUp];
    
    NSString* filePath = [[NSBundle bundleForClass:[JSONModel class]].resourcePath stringByAppendingPathComponent:@"converts.json"];
    NSString* jsonContents = [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil];
    
    STAssertNotNil(jsonContents, @"Can't fetch test data file contents.");
    
    NSError* err;
    b = [[BuiltInConversionsModel alloc] initWithString: jsonContents error:&err];
    STAssertNil(err, [err localizedDescription]);
    STAssertNotNil(b, @"Could not load the test data file.");
}

-(void)testConversions
{
    STAssertTrue(b.isItYesOrNo==YES, @"isItYesOrNo value is not YES");
    
    STAssertTrue(b.boolFromBoolean==YES, @"boolFromBoolean is not YES");
    STAssertTrue(b.boolFromNumber==YES, @"boolFromNumber is not YES");
    STAssertTrue(b.boolFromString==YES, @"boolFromString is not YES");
    
    
    STAssertTrue([b.unorderedList isKindOfClass:[NSSet class]], @"unorderedList is not an NSSet object");
    STAssertTrue([b.unorderedList anyObject], @"unorderedList don't have any objects");
    
    STAssertTrue([b.dynamicUnorderedList isKindOfClass:[NSMutableSet class]], @"dynamicUnorderedList is not an NSMutableSet object");
    STAssertTrue([b.dynamicUnorderedList anyObject], @"dynamicUnorderedList don't have any objects");

#ifdef __IPHONE_OS_VERSION_MAX_ALLOWED
    int nrOfObjects = [b.dynamicUnorderedList allObjects].count;
#else
    NSUInteger nrOfObjects = [b.dynamicUnorderedList allObjects].count;
#endif
    
    [b.dynamicUnorderedList addObject:@"ADDED"];
    STAssertTrue(nrOfObjects + 1 == [b.dynamicUnorderedList allObjects].count, @"dynamicUnorderedList didn't add an object");
    
    STAssertTrue([b.stringFromNumber isKindOfClass:[NSString class]], @"stringFromNumber is not an NSString");
    STAssertTrue([b.stringFromNumber isEqualToString:@"19.95"], @"stringFromNumber's value is not 19.95");
    
    STAssertTrue([b.numberFromString isKindOfClass:[NSNumber class]], @"numberFromString is not an NSNumber");
    
    //TODO: I had to hardcode the float epsilon below, bcz actually [NSNumber floatValue] was returning a bigger deviation than FLT_EPSILON
    // IDEAS?
    STAssertTrue(fabsf([b.numberFromString floatValue]-1230.99)<0.001, @"numberFromString's value is not 1230.99");
    
    STAssertTrue([b.importantEvent isKindOfClass:[NSDate class]], @"importantEvent is not an NSDate");
    STAssertTrue((long)[b.importantEvent timeIntervalSince1970] == 1353916801, @"importantEvent value was not read properly");

    // Test dates with milliseconds
    STAssertTrue([b.importantEventWithMilliSec isKindOfClass:[NSDate class]], @"importantEventWithMilliSec is not an NSDate");
    STAssertTrue((long)[b.importantEventWithMilliSec timeIntervalSince1970] == 1353916801, @"importantEventWithMilliSec value was not read properly");
    
    //test for a valid URL
    //https://github.com/icanzilb/JSONModel/pull/60
//    STAssertNotNil(b.websiteURL, @"URL parsing did return nil");
//    STAssertNotNil(b.websiteURL.query, @"key1=test");
}

@end
