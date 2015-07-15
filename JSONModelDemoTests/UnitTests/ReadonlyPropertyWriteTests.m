//
//  ReadonlyPropertyWriteTests.m
//  JSONModelDemo_OSX
//
//  Created by Vaňo Jakub on 15/07/15.
//  Copyright (c) 2015 Underplot ltd. All rights reserved.
//

#import "ReadonlyPropertyWriteTests.h"
#import "ImmutableModel.h"

@implementation ReadonlyPropertyWriteTests
{
    ImmutableModel* i;
}

- (void)testAllPropertiesPresent
{
    i = [[ImmutableModel alloc] initWithRequired:@"I'm here!"
                                        optional:@"I'm here!"
                                          ignore:@"I'm here!"];
    
    XCTAssertNotNil(i, @"ImmutableModel init failed");
    
    NSDictionary* dict = [i toDictionary];
    
    XCTAssertNotNil(dict, @"-toDictionary failed");
    
    XCTAssertTrue([[dict objectForKey:@"readonlyRequired"] isEqualToString:@"I'm here!"], @"readonlyRequired' value is not 'I'm here!'");
    XCTAssertTrue([[dict objectForKey:@"readonlyOptional"] isEqualToString:@"I'm here!"], @"readonlyOptional' value is not 'I'm here!'");
    XCTAssertNil([dict objectForKey:@"readonlyIgnore"], @"readonlyIgnore' value is not nil");
}

- (void)testRequiredPropertyMissing
{
    i = [[ImmutableModel alloc] initWithRequired:nil
                                        optional:@"I'm here!"
                                          ignore:@"I'm here!"];
    
    XCTAssertNotNil(i, @"ImmutableModel init failed");
    
    NSDictionary* dict = [i toDictionary];
    
    XCTAssertNotNil(dict, @"-toDictionary failed");
    
    XCTAssertTrue([[dict objectForKey:@"readonlyRequired"] isEqual: [NSNull null]], @"readonlyRequired' value is not NSNull");
    XCTAssertTrue([[dict objectForKey:@"readonlyOptional"] isEqualToString:@"I'm here!"], @"readonlyOptional' value is not 'I'm here!'");
    XCTAssertNil([dict objectForKey:@"readonlyIgnore"], @"readonlyIgnore' value is not nil");
}

- (void)testOptionalPropertyMissing
{
    i = [[ImmutableModel alloc] initWithRequired:@"I'm here!"
                                        optional:nil
                                          ignore:@"I'm here!"];
    
    XCTAssertNotNil(i, @"ImmutableModel init failed");
    
    NSDictionary* dict = [i toDictionary];
    
    XCTAssertNotNil(dict, @"-toDictionary failed");
    
    XCTAssertTrue([[dict objectForKey:@"readonlyRequired"] isEqualToString:@"I'm here!"], @"readonlyRequired' value is not 'I'm here!'");
    XCTAssertNil([dict objectForKey:@"readonlyOptional"], @"readonlyOptional' value is not nil");
    XCTAssertNil([dict objectForKey:@"readonlyIgnore"], @"readonlyIgnore' value is not nil");
}

- (void)testIgnorePropertyMissing
{
    i = [[ImmutableModel alloc] initWithRequired:@"I'm here!"
                                        optional:@"I'm here!"
                                          ignore:nil];
    
    XCTAssertNotNil(i, @"ImmutableModel init failed");
    
    NSDictionary* dict = [i toDictionary];
    
    XCTAssertNotNil(dict, @"-toDictionary failed");
    
    XCTAssertTrue([[dict objectForKey:@"readonlyRequired"] isEqualToString:@"I'm here!"], @"readonlyRequired' value is not 'I'm here!'");
    XCTAssertTrue([[dict objectForKey:@"readonlyOptional"] isEqualToString:@"I'm here!"], @"readonlyOptional' value is not 'I'm here!'");
    XCTAssertNil([dict objectForKey:@"readonlyIgnore"], @"readonlyIgnore' value is not nil");
}

@end
