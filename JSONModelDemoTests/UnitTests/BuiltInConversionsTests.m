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
    
    NSAssert(jsonContents, @"Can't fetch test data file contents.");
    
    NSError* err;
    b = [[BuiltInConversionsModel alloc] initWithString: jsonContents error:&err];
    NSAssert(!err, [err localizedDescription]);
    
    NSAssert(b, @"Could not load the test data file.");
}

-(void)testConversions
{
    NSAssert(b.isItYesOrNo==YES, @"isItYesOrNo value is not YES");
    
    NSAssert([b.unorderedList isKindOfClass:[NSSet class]], @"unorderedList is not an NSSet object");
    NSAssert([b.unorderedList anyObject], @"unorderedList don't have any objects");
    
    NSAssert([b.dynamicUnorderedList isKindOfClass:[NSMutableSet class]], @"dynamicUnorderedList is not an NSMutableSet object");
    NSAssert([b.dynamicUnorderedList anyObject], @"dynamicUnorderedList don't have any objects");

#ifdef __IPHONE_OS_VERSION_MAX_ALLOWED
    int nrOfObjects = [b.dynamicUnorderedList allObjects].count;
#else
    NSUInteger nrOfObjects = [b.dynamicUnorderedList allObjects].count;
#endif
    
    [b.dynamicUnorderedList addObject:@"ADDED"];
    NSAssert(nrOfObjects + 1 == [b.dynamicUnorderedList allObjects].count, @"dynamicUnorderedList didn't add an object");
    
    NSAssert([b.stringFromNumber isKindOfClass:[NSString class]], @"stringFromNumber is not an NSString");
    NSAssert([b.stringFromNumber isEqualToString:@"19.95"], @"stringFromNumber's value is not 19.95");
    
    NSAssert([b.numberFromString isKindOfClass:[NSNumber class]], @"numberFromString is not an NSNumber");
    
    //TODO: I had to hardcode the float epsilon below, bcz actually [NSNumber floatValue] was returning a bigger deviation than FLT_EPSILON
    // IDEAS?
    NSAssert(fabsf([b.numberFromString floatValue]-1230.99)<0.001, @"numberFromString's value is not 1230.99");
    
    NSAssert([b.importantEvent isKindOfClass:[NSDate class]], @"importantEvent is not an NSDate");
    NSAssert((long)[b.importantEvent timeIntervalSince1970] == 1353916801, @"importantEvent value was not read properly");
    
    //test for a valid URL
    //https://github.com/icanzilb/JSONModel/pull/60
    NSAssert(b.websiteURL, @"URL parsing did return nil");
    NSAssert(b.websiteURL.query, @"key1=test");
}

@end
