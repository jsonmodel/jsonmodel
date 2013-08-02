//
//  JSONAPITests.m
//  JSONModelDemo_iOS
//
//  Created by Marin Todorov on 4/2/13.
//  Copyright (c) 2013 Underplot ltd. All rights reserved.
//

#import "JSONAPITests.h"
#import "MockNSURLConnection.h"
#import "MTTestSemaphor.h"

#import "JSONModelLib.h"
#import "RpcRequestModel.h"

@implementation JSONAPITests

-(void)testBaseURL
{
    //check if the header is sent along the http request
    NSString* apiBaseUrlString = @"http://localhost/test.json/";
    NSString* semaphorKey = @"testBaseURL";
    
    [JSONAPI setAPIBaseURLWithString: apiBaseUrlString];
    [JSONAPI getWithPath: semaphorKey
               andParams: nil
              completion:^(NSDictionary *json, JSONModelError *err) {
                  
                  NSURLRequest* request = [NSURLConnection lastRequest];
                  NSString* absString = [request.URL absoluteString];
                  STAssertTrue([absString hasPrefix: apiBaseUrlString], @"URL request not start with base URL");
                  
                  [[MTTestSemaphor semaphore] lift: semaphorKey];
                  
              }];
    
    [[MTTestSemaphor semaphore] waitForKey: semaphorKey];
}

-(void)testContentType
{
    //check if the header is sent along the http request
    NSString* apiBaseUrlString = @"http://localhost/test.json/";
    NSString* semaphorKey = @"testContentType";
    
    NSString* ctype = @"MyCustomType";
    
    [JSONAPI setAPIBaseURLWithString: apiBaseUrlString];
    [JSONAPI setContentType: ctype];
    [JSONAPI getWithPath: semaphorKey
               andParams: nil
              completion:^(NSDictionary *json, JSONModelError *err) {
                  
                  NSURLRequest* request = [NSURLConnection lastRequest];
                  STAssertTrue([[request valueForHTTPHeaderField:@"Content-type"] hasPrefix:ctype], @"request content type was not MyCustomType");
                  
                  [[MTTestSemaphor semaphore] lift: semaphorKey];
                  [JSONHTTPClient setRequestContentType:kContentTypeAutomatic];
                  
                  [[MTTestSemaphor semaphore] lift: semaphorKey];
                  
              }];
    
    [[MTTestSemaphor semaphore] waitForKey: semaphorKey];
}

-(void)testGetAPIRequests
{
    //check if the header is sent along the http request
    NSString* apiBaseUrlString = @"http://localhost/test.json/";
    NSString* semaphorKey = @"testGetAPIRequests";
    
    [JSONAPI setAPIBaseURLWithString: apiBaseUrlString];
    
    //test GET method, no params
    [JSONAPI getWithPath: semaphorKey
               andParams: nil
              completion:^(NSDictionary *json, JSONModelError *err) {
                  
                  NSURLRequest* request = [NSURLConnection lastRequest];
                  NSString* absString = [request.URL absoluteString];
                  NSString* desiredString = @"http://localhost/test.json/testGetAPIRequests";
                  STAssertTrue( [absString isEqualToString: desiredString] , @"URL does not match");
                  
                  [[MTTestSemaphor semaphore] lift: semaphorKey];
                  
              }];
    [[MTTestSemaphor semaphore] waitForKey: semaphorKey];
    
    //test GET method, with params
    [JSONAPI getWithPath: semaphorKey
               andParams: @{@"key2":@"marin",@"key1":@"ma rin"}
              completion:^(NSDictionary *json, JSONModelError *err) {
                  
                  NSURLRequest* request = [NSURLConnection lastRequest];
                  NSString* absString = [request.URL absoluteString];
                  NSString* desiredString = @"http://localhost/test.json/testGetAPIRequests?key1=ma%20rin&key2=marin";
                  STAssertTrue( [absString isEqualToString: desiredString] , @"URL does not match");
                  
                  [[MTTestSemaphor semaphore] lift: semaphorKey];
                  
              }];
    [[MTTestSemaphor semaphore] waitForKey: semaphorKey];
}

-(void)testPostAPIRequests
{
    //check if the header is sent along the http request
    NSString* apiBaseUrlString = @"http://localhost/test.json/";
    NSString* semaphorKey = @"testPostAPIRequests";
    
    [JSONAPI setAPIBaseURLWithString: apiBaseUrlString];
    
    //test POST method, with params
    [JSONAPI postWithPath: semaphorKey
                andParams: @{@"key2":@"marin",@"key1":@"ma rin"}
               completion:^(NSDictionary *json, JSONModelError *err) {
                  
                  NSURLRequest* request = [NSURLConnection lastRequest];
                  NSString* absString = [request.URL absoluteString];
                  NSString* desiredString = @"http://localhost/test.json/testPostAPIRequests";
                  STAssertTrue( [absString isEqualToString: desiredString] , @"URL does not match");
                
                   NSString* paramsSent = [[NSString alloc] initWithData:[request HTTPBody] encoding:NSUTF8StringEncoding];
                   STAssertTrue([paramsSent isEqualToString: @"key1=ma%20rin&key2=marin"], @"request body data did not match the post encoded params");
                  
                  [[MTTestSemaphor semaphore] lift: semaphorKey];
                  
               }];
    [[MTTestSemaphor semaphore] waitForKey: semaphorKey];
}

-(void)testRpcRequest
{
    //check if the header is sent along the http request
    NSString* apiBaseUrlString = @"http://localhost/test.json/";
    NSString* semaphorKey = @"testRpcRequest";
    
    [JSONAPI setAPIBaseURLWithString: apiBaseUrlString];
    
    //test RPC method, no params
    [JSONAPI rpcWithMethodName:semaphorKey
                  andArguments:nil
                    completion:^(NSDictionary *json, JSONModelError *err) {
                        
                        NSURLRequest* request = [NSURLConnection lastRequest];
                        NSString* absString = [request.URL absoluteString];
                        NSString* desiredString = @"http://localhost/test.json/";
                        STAssertTrue([absString isEqualToString: desiredString], @"URL does not match");
                        
                        NSString* jsonSent = [[NSString alloc] initWithData:[request HTTPBody] encoding:NSUTF8StringEncoding];
                        RpcRequestModel* jsonRequest = [[RpcRequestModel alloc] initWithString:jsonSent error:nil];
                        STAssertNotNil(jsonRequest, @"RPC request is not valid");
                        
                        STAssertNotNil(jsonRequest.id, @"id is nil");
                        STAssertTrue([jsonRequest.params count]==0, @"params not an empty array");
                        STAssertTrue([jsonRequest.method isEqualToString: semaphorKey], @"method name does not match");
                        
                        [[MTTestSemaphor semaphore] lift: semaphorKey];
                    }];
    
    [[MTTestSemaphor semaphore] waitForKey: semaphorKey];
    
    //test RPC method, with params
    [JSONAPI rpcWithMethodName:semaphorKey
                  andArguments:@[@"chicken", @1, @[@"semi",@"conductor"]]
                    completion:^(NSDictionary *json, JSONModelError *err) {
                        
                        NSURLRequest* request = [NSURLConnection lastRequest];
                        NSString* jsonSent = [[NSString alloc] initWithData:[request HTTPBody] encoding:NSUTF8StringEncoding];
                        RpcRequestModel* jsonRequest = [[RpcRequestModel alloc] initWithString:jsonSent error:nil];
                        STAssertNotNil(jsonRequest, @"RPC request is not valid");
                        
                        STAssertTrue([jsonRequest.params[0] isEqualToString: @"chicken"], @"first param is not chicken");
                        STAssertTrue([jsonRequest.params[1] isEqualToNumber:@1], @"second param is not 1");
                        STAssertTrue([jsonRequest.params[2] count]==2, @"third param is not 2 element array");
                        
                        [[MTTestSemaphor semaphore] lift: semaphorKey];
                    }];
    
    [[MTTestSemaphor semaphore] waitForKey: semaphorKey];
    
}

@end
