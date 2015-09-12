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
    
    XCTAssertNotNil(jsonContents, @"Can't fetch test data file contents.");
    
    NSError* err;
    p = [[PrimitivesModel alloc] initWithString: jsonContents error:&err];
    
    XCTAssertNil(err, "%@", [err localizedDescription]);
    
    XCTAssertNotNil(p, @"Could not load the test data file.");
}

-(void)testPrimitiveTypes
{
    XCTAssertTrue(p.shortNumber==114, @"shortNumber read fail");
    XCTAssertTrue(p.intNumber==12, @"intNumber read fail");
    XCTAssertTrue(p.longNumber==12124, @"longNumber read fail");
    
    XCTAssertEqualWithAccuracy(p.floatNumber, 12.12, FLT_EPSILON, @"floatNumber read fail");
    XCTAssertEqualWithAccuracy(p.doubleNumber, 121231312.124, DBL_EPSILON, @"doubleNumber read fail");
    
    XCTAssertTrue(p.boolNO==NO, @"boolNO read fail");
    XCTAssertTrue(p.boolYES==YES, @"boolYES read fail");
}

-(void)testBoolExport
{
    NSString* exportedJSON = [p toJSONString];
    XCTAssertTrue([exportedJSON rangeOfString:@"\"boolNO\":false"].location != NSNotFound, @"boolNO should export to 'false'");
    XCTAssertTrue([exportedJSON rangeOfString:@"\"boolYES\":true"].location != NSNotFound, @"boolYES should export to 'true'");
}

#if __IPHONE_OS_VERSION_MIN_REQUIRED >= 60000
-(void)testEnumerationTypes
{
    NSString* jsonContents = @"{\"nested\":{\"status\":\"open\"},\"nsStatus\":\"closed\",\"nsuStatus\":\"open\",\"statusString\":\"open\"}";

    NSError* err;
    EnumModel* p1 = [[EnumModel alloc] initWithString: jsonContents error:&err];
    XCTAssertNil(err, "%@", [err localizedDescription]);
    
    XCTAssertNotNil(p1, @"Could not read input json text");
    
    XCTAssertTrue(p1.status==StatusOpen, @"Status is not StatusOpen");
    XCTAssertTrue(p1.nsStatus==NSE_StatusClosed, @"nsStatus is not NSE_StatusClosed");
    XCTAssertTrue(p1.nsuStatus==NSEU_StatusOpen, @"nsuStatus is not NSEU_StatusOpen");

    NSString* json = [p1 toJSONString];
    XCTAssertTrue([json rangeOfString:@"\"statusString\":\"open\""].location!=NSNotFound, @"Exporting enum value didn't work out");
    XCTAssertTrue([json rangeOfString:@"\"nsuStatus\":\"open\""].location!=NSNotFound, @"Exporting enum value didn't work out");
    XCTAssertTrue([json rangeOfString:@"\"nsStatus\":\"closed\""].location!=NSNotFound, @"Exporting enum value didn't work out");
}
#endif

@end
