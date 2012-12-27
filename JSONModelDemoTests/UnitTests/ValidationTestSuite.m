//
//  ValidationTestSuite.m
//  JSONModelDemo
//
//  Created by Marin Todorov on 17/12/2012.
//  Copyright (c) 2012 Underplot ltd. All rights reserved.
//

#import "ValidationTestSuite.h"
#import "JSONTypesModelWithValidation1.h"
#import "JSONTypesModelWithValidation2.h"

@implementation ValidationTestSuite
{
    NSString* jsonContents;
}

-(void)setUp
{
    [super setUp];
    
    NSString* filePath = [[NSBundle bundleForClass:[JSONModel class]].resourcePath stringByAppendingPathComponent:@"jsonTypes.json"];
    jsonContents = [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil];
}

-(void)testValidData
{
    NSError* err;
    JSONTypesModelWithValidation1* val1 = [[JSONTypesModelWithValidation1 alloc] initWithString:jsonContents error:&err];
    NSAssert(val1, @"Model didn't initialize");
    NSAssert(!err, @"Model is not nil, but there's an error back from init");
    
}

-(void)testInvalidData
{
    NSError* err;
    JSONTypesModelWithValidation2* val2 = [[JSONTypesModelWithValidation2 alloc] initWithString:jsonContents error:&err];
    NSAssert(!val2, @"Model did initialize with wrong data");
    NSAssert(err.code == kJSONModelErrorModelIsInvalid, @"Error code is not kJSONModelErrorModelIsInvalid");
    
}

@end
