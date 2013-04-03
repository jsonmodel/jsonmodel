//
//  InitFromWebTests.m
//  JSONModelDemo_iOS
//
//  Created by Marin Todorov on 4/3/13.
//  Copyright (c) 2013 Underplot ltd. All rights reserved.
//

#import "InitFromWebTests.h"
#import "JSONModelLib.h"
#import "MockNSURLConnection.h"
#import "MTTestSemaphor.h"

#import "NestedModel.h"

@implementation InitFromWebTests
{
    NSString* jsonContents;
}

-(void)setUp
{
    [super setUp];
    
    NSString* filePath = [[NSBundle bundleForClass:[JSONModel class]].resourcePath stringByAppendingPathComponent:@"nestedData.json"];
    jsonContents = [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil];
    
    NSAssert(jsonContents, @"Can't fetch test data file contents.");
}

-(void)testInitFromWeb
{
    NSString* jsonURLString = @"http://localhost/test.json?testInitFromWeb";
    NSString* semaphorKey = @"testInitFromWeb";
    
    NSURLResponse* response = [[NSURLResponse alloc] initWithURL: [NSURL URLWithString:jsonURLString]
                                                        MIMEType: @"application/json"
                                           expectedContentLength: [jsonContents length]
                                                textEncodingName: @"UTF-8"];
    
    [NSURLConnection setNextResponse:response data:[jsonContents dataUsingEncoding:NSUTF8StringEncoding] error:nil];
    [NSURLConnection setResponseDelay:1];
    
    __block NestedModel* nested = [[NestedModel alloc] initFromURLWithString:jsonURLString
                                                          completion:^(NestedModel *model, JSONModelError *err) {
                                                              
                                                              NSAssert(nested==model, @"async initialization didn't work");
                                                              NSAssert(model.images.count>0, @"content not initialized from async init");
                                                              
                                                              [NSURLConnection setResponseDelay:0];
                                                              [[MTTestSemaphor semaphore] lift: semaphorKey];
                                                          }];
    
    NSAssert(nested.isLoading, @"isLoading property not set during load");
    [[MTTestSemaphor semaphore] waitForKey: semaphorKey];
}

@end
