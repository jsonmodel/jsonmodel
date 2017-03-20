//
//  PrimitiveTypesReadTests.m
//  JSONModelDemo
//
//  Created by Marin Todorov on 02/12/2012.
//  Copyright (c) 2012 Underplot ltd. All rights reserved.
//

@import XCTest;

#import "PrimitivesModel.h"

#if __IPHONE_OS_VERSION_MIN_REQUIRED >= 60000
#import "EnumModel.h"
#endif

@interface PrimitiveTypesReadTests : XCTestCase
@end

@implementation PrimitiveTypesReadTests
{
	PrimitivesModel* p;
}

-(void)setUp
{
	[super setUp];

	NSString* filePath = [[NSBundle bundleForClass:[JSONModel class]].resourcePath stringByAppendingPathComponent:@"../../primitives.json"];
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
	
	XCTAssertTrue(p.unsignedIntNumber==6666, @"unsignedIntNumber read fail");
	XCTAssertTrue(p.unsignedLongNumber==666666, @"unsignedLongNumber read fail");
	XCTAssertTrue(p.longLongNumber==121231312, @"longLongNumber read fail");
	XCTAssertTrue(p.unsignedLongLongNumber==4121231312, @"unsignedLongLongNumber read fail");
	XCTAssertTrue(p.unsignedShortNumber==5555, @"unsignedShortNumber read fail");
	XCTAssertTrue(p.charNumber==30, @"charNumber read fail");
	XCTAssertTrue(p.unsignedCharNumber==255, @"unsignedCharNumber read fail");
}

-(void)testBoolExport
{
	NSString* exportedJSON = [p toJSONString];
	XCTAssertTrue([exportedJSON rangeOfString:@"\"boolNO\":false"].location != NSNotFound, @"boolNO should export to 'false'");
	XCTAssertTrue([exportedJSON rangeOfString:@"\"boolYES\":true"].location != NSNotFound, @"boolYES should export to 'true'");
}

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

-(void)testCustomSetters
{
	NSString* json1 = @"{\"nested\":{\"status\":\"open\"},\"nsStatus\":\"closed\",\"nsuStatus\":\"open\",\"statusString\":\"open\"}";
	NSString* json2 = @"{\"nested\":{\"status\":true},\"nsStatus\":\"closed\",\"nsuStatus\":\"open\",\"statusString\":\"open\"}";
	NSString* json3 = @"{\"nested\":{\"status\":[\"open\"]},\"nsStatus\":\"closed\",\"nsuStatus\":\"open\",\"statusString\":\"open\"}";
	NSString* json4 = @"{\"nested\":{\"status\":{}},\"nsStatus\":\"closed\",\"nsuStatus\":\"open\",\"statusString\":\"open\"}";

	NSError* err;

	EnumModel* p1 = [[EnumModel alloc] initWithString: json1 error:&err];
	XCTAssertNil(err, "%@", [err localizedDescription]);
	XCTAssertNotNil(p1, @"Could not read input json text");

	EnumModel* p2 = [[EnumModel alloc] initWithString: json2 error:&err];
	XCTAssertNil(err, "%@", [err localizedDescription]);
	XCTAssertNotNil(p2, @"Could not read input json text");

	EnumModel* p3 = [[EnumModel alloc] initWithString: json3 error:&err];
	XCTAssertNil(err, "%@", [err localizedDescription]);
	XCTAssertNotNil(p3, @"Could not read input json text");

	EnumModel* p4 = [[EnumModel alloc] initWithString: json4 error:&err];
	XCTAssertNil(err, "%@", [err localizedDescription]);
	XCTAssertNotNil(p4, @"Could not read input json text");

	XCTAssertTrue(p1.status==StatusOpen, @"Status is not StatusOpen");
	XCTAssertTrue(p1.nsStatus==NSE_StatusClosed, @"nsStatus is not NSE_StatusClosed");
	XCTAssertTrue(p1.nsuStatus==NSEU_StatusOpen, @"nsuStatus is not NSEU_StatusOpen");

	XCTAssertTrue(p2.status==StatusOpen, @"Status is not StatusOpen");
	XCTAssertTrue(p2.nsStatus==NSE_StatusClosed, @"nsStatus is not NSE_StatusClosed");
	XCTAssertTrue(p2.nsuStatus==NSEU_StatusOpen, @"nsuStatus is not NSEU_StatusOpen");

	XCTAssertTrue(p3.status==StatusOpen, @"Status is not StatusOpen");
	XCTAssertTrue(p3.nsStatus==NSE_StatusClosed, @"nsStatus is not NSE_StatusClosed");
	XCTAssertTrue(p3.nsuStatus==NSEU_StatusOpen, @"nsuStatus is not NSEU_StatusOpen");

	XCTAssertTrue(p4.status==StatusClosed, @"Status is not StatusOpen");
	XCTAssertTrue(p4.nsStatus==NSE_StatusClosed, @"nsStatus is not NSE_StatusClosed");
	XCTAssertTrue(p4.nsuStatus==NSEU_StatusOpen, @"nsuStatus is not NSEU_StatusOpen");

	NSString* out1 = [p1 toJSONString];
	XCTAssertTrue([out1 rangeOfString:@"\"statusString\":\"open\""].location!=NSNotFound, @"Exporting enum value didn't work out");
	XCTAssertTrue([out1 rangeOfString:@"\"nsuStatus\":\"open\""].location!=NSNotFound, @"Exporting enum value didn't work out");
	XCTAssertTrue([out1 rangeOfString:@"\"nsStatus\":\"closed\""].location!=NSNotFound, @"Exporting enum value didn't work out");

	NSString* out2 = [p2 toJSONString];
	XCTAssertTrue([out2 rangeOfString:@"\"statusString\":\"open\""].location!=NSNotFound, @"Exporting enum value didn't work out");
	XCTAssertTrue([out2 rangeOfString:@"\"nsuStatus\":\"open\""].location!=NSNotFound, @"Exporting enum value didn't work out");
	XCTAssertTrue([out2 rangeOfString:@"\"nsStatus\":\"closed\""].location!=NSNotFound, @"Exporting enum value didn't work out");

	NSString* out3 = [p3 toJSONString];
	XCTAssertTrue([out3 rangeOfString:@"\"statusString\":\"open\""].location!=NSNotFound, @"Exporting enum value didn't work out");
	XCTAssertTrue([out3 rangeOfString:@"\"nsuStatus\":\"open\""].location!=NSNotFound, @"Exporting enum value didn't work out");
	XCTAssertTrue([out3 rangeOfString:@"\"nsStatus\":\"closed\""].location!=NSNotFound, @"Exporting enum value didn't work out");

	NSString* out4 = [p4 toJSONString];
	XCTAssertTrue([out4 rangeOfString:@"\"statusString\":\"closed\""].location!=NSNotFound, @"Exporting enum value didn't work out");
	XCTAssertTrue([out4 rangeOfString:@"\"nsuStatus\":\"open\""].location!=NSNotFound, @"Exporting enum value didn't work out");
	XCTAssertTrue([out4 rangeOfString:@"\"nsStatus\":\"closed\""].location!=NSNotFound, @"Exporting enum value didn't work out");
}

@end
