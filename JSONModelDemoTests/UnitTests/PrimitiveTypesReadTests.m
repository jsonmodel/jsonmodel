//
//  PrimitiveTypesReadTests.m
//  JSONModelDemo
//
//  Created by Marin Todorov on 02/12/2012.
//  Copyright (c) 2012 Underplot ltd. All rights reserved.
//

#import "PrimitiveTypesReadTests.h"
#import "PrimitivesModel.h"

@implementation PrimitiveTypesReadTests
{
    PrimitivesModel* p;
}

-(void)setUp
{
    [super setUp];
    
    NSString* filePath = [[NSBundle mainBundle].resourcePath stringByAppendingPathComponent:@"primitives.json"];
    NSString* jsonContents = [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil];
    
    NSAssert(jsonContents, @"Can't fetch test data file contents.");
    
    NSError* err;
    p = [[PrimitivesModel alloc] initWithString: jsonContents error:&err];
    NSAssert(!err, [err localizedDescription]);
    
    NSAssert(p, @"Could not load the test data file.");
}

-(void)testPrimitiveTypes
{
    NSAssert(p.shortNumber==114, @"shortNumber read fail");
    NSAssert(p.intNumber==12, @"intNumber read fail");
    NSAssert(p.longNumber==12124, @"longNumber read fail");
    
    NSAssert(fabsf(p.floatNumber-12.12)<FLT_EPSILON, @"floatNumber read fail");
    NSAssert(fabs(p.doubleNumber-121231312.124)<DBL_EPSILON, @"doubleNumber read fail");
    
    
    NSAssert(p.boolNO==NO, @"boolNO read fail");
    NSAssert(p.boolYES==YES, @"boolYES read fail");
}

@end
