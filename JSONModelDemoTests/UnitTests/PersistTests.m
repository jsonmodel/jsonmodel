//
//  PersistTests.m
//  JSONModelDemo
//
//  Created by Marin Todorov on 16/12/2012.
//  Copyright (c) 2012 Underplot ltd. All rights reserved.
//

#import "PersistTests.h"
#import "JSONTypesModel.h"

@implementation PersistTests

-(void)testPersistJSONTypes
{
    //---------------------------------------
    // load JSON file
    //---------------------------------------
    
    NSString* filePath = [[NSBundle bundleForClass:[JSONModel class]].resourcePath stringByAppendingPathComponent:@"jsonTypes.json"];
    NSString* jsonContents = [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil];
    
    STAssertNotNil(jsonContents, @"Can't fetch test data file contents.");
    
    NSError* err;
    JSONTypesModel* t = [[JSONTypesModel alloc] initWithString: jsonContents error:&err];
    STAssertNil(err, [err localizedDescription]);
    STAssertNotNil(t, @"Could not load the test data file.");

    //---------------------------------------
    // export model to NSDictionary
    //---------------------------------------
    
    NSDictionary* d = [t toDictionary];
    STAssertNotNil(d, @"toDictionary returned nil");
    STAssertTrue([d isKindOfClass:[NSDictionary class]], @"toDictionary didn't return NSDictionary object");
    
    STAssertTrue( [t.caption isEqualToString: d[@"caption"] ], @"caption key is not equal to exported value");
    
    //---------------------------------------
    // turn NSDictionary to a model
    //---------------------------------------

    JSONTypesModel* t1 = [[JSONTypesModel alloc] initWithDictionary:d error:&err];
    STAssertNil(err, [err localizedDescription]);
    
    STAssertTrue( [t1.caption isEqualToString:t.caption], @"t1.caption != t.caption" );
    STAssertTrue( t1.notAvailable==t.notAvailable, @"t1.notAvailable != t.notAvailable" );

    //---------------------------------------
    // export model to JSON
    //---------------------------------------
    
    NSString* json = [t1 toJSONString];
    STAssertNotNil(json, @"Exported JSON is nil");
    
    //---------------------------------------
    // turn exported JSON to a model
    //---------------------------------------
    
    JSONTypesModel* t2 = [[JSONTypesModel alloc] initWithString:json error:&err];
    STAssertNil(err, [err localizedDescription]);

    STAssertTrue([t1.caption isEqualToString:t2.caption], @"t1.caption != t2.caption" );
    STAssertTrue(t1.notAvailable==t2.notAvailable, @"t1.notAvailable != t2.notAvailable" );
}

@end
