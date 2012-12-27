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
    
    NSAssert(jsonContents, @"Can't fetch test data file contents.");
    
    NSError* err;
    JSONTypesModel* t = [[JSONTypesModel alloc] initWithString: jsonContents error:&err];
    NSAssert(!err, [err localizedDescription]);
    
    NSAssert(t, @"Could not load the test data file.");

    //---------------------------------------
    // export model to NSDictionary
    //---------------------------------------
    
    NSDictionary* d = [t toDictionary];
    NSAssert(d, @"toDictionary returned nil");
    NSAssert([d isKindOfClass:[NSDictionary class]], @"toDictionary didn't return NSDictionary object");
    
    NSAssert( [t.caption isEqualToString: d[@"caption"] ], @"caption key is not equal to exported value");
    
    //---------------------------------------
    // turn NSDictionary to a model
    //---------------------------------------

    JSONTypesModel* t1 = [[JSONTypesModel alloc] initWithDictionary:d error:&err];
    NSAssert(!err, [err localizedDescription]);
    
    NSAssert( [t1.caption isEqualToString:t.caption], @"t1.caption != t.caption" );
    NSAssert( t1.notAvailable==t.notAvailable, @"t1.notAvailable != t.notAvailable" );

    //---------------------------------------
    // export model to JSON
    //---------------------------------------
    
    NSString* json = [t1 toJSONString];
    NSAssert(json, @"Exported JSON is nil");
    
    //---------------------------------------
    // turn exported JSON to a model
    //---------------------------------------
    
    JSONTypesModel* t2 = [[JSONTypesModel alloc] initWithString:json error:&err];
    NSAssert(!err, [err localizedDescription]);

    NSAssert( [t1.caption isEqualToString:t2.caption], @"t1.caption != t2.caption" );
    NSAssert( t1.notAvailable==t2.notAvailable, @"t1.notAvailable != t2.notAvailable" );

}

@end
