//
//  PrimitiveTypesReadTests.m
//  JSONModelDemo
//
//  Created by Marin Todorov on 02/12/2012.
//  Copyright (c) 2012 Underplot ltd. All rights reserved.
//

#import "PrimitiveTypesReadTests.h"
#import "PrimitivesModel.h"

#if __IPHONE_OS_VERSION_MIN_REQUIRED >= 60000
#import "EnumModel.h"
#endif

@implementation PrimitiveTypesReadTests
{
    PrimitivesModel* p;
}

-(void)setUp
{
    [super setUp];
    
    NSString* filePath = [[NSBundle bundleForClass:[JSONModel class]].resourcePath stringByAppendingPathComponent:@"primitives.json"];
    NSString* jsonContents = [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil];
    
    STAssertNotNil(jsonContents, @"Can't fetch test data file contents.");
    
    NSError* err;
    p = [[PrimitivesModel alloc] initWithString: jsonContents error:&err];
    
    STAssertNil(err, [err localizedDescription]);
    
    STAssertNotNil(p, @"Could not load the test data file.");
}

-(void)testPrimitiveTypes
{
    STAssertTrue(p.shortNumber==114, @"shortNumber read fail");
    STAssertTrue(p.intNumber==12, @"intNumber read fail");
    STAssertTrue(p.longNumber==12124, @"longNumber read fail");
    
    STAssertTrue(fabsf(p.floatNumber-12.12)<FLT_EPSILON, @"floatNumber read fail");
    STAssertTrue(fabs(p.doubleNumber-121231312.124)<DBL_EPSILON, @"doubleNumber read fail");
    
    
    STAssertTrue(p.boolNO==NO, @"boolNO read fail");
    STAssertTrue(p.boolYES==YES, @"boolYES read fail");
}

#if __IPHONE_OS_VERSION_MIN_REQUIRED >= 60000
-(void)testEnumerationTypes
{
    NSString* jsonContents = @"{\"statusString\":\"open\",\"nsStatus\":\"closed\",\"nsuStatus\":\"open\",\"nested\":{\"status\":\"open\"}}";
    
    NSError* err1;
    EnumModel* p1 = [[EnumModel alloc] initWithString: jsonContents error:&err1];
    STAssertNil(err1, [err1 localizedDescription]);
    
    STAssertNotNil(p1, @"Could not read input json text");
    
    STAssertTrue(p1.status==StatusOpen, @"Status is not StatusOpen");
    STAssertTrue(p1.nsStatus==NSE_StatusClosed, @"nsStatus is not NSE_StatusClosed");
    STAssertTrue(p1.nsuStatus==NSEU_StatusOpen, @"nsuStatus is not NSEU_StatusOpen");

    STAssertTrue([[p1 toJSONString] isEqualToString: jsonContents], @"Exporting enum value didn't work out");
}
#endif

@end
