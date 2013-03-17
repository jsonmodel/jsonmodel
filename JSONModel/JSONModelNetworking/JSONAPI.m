//
//  JSONAPI.m
//
//  @version 0.8.4
//  @author Marin Todorov, http://www.touch-code-magazine.com
//

// Copyright (c) 2012 Marin Todorov, Underplot ltd.
// This code is distributed under the terms and conditions of the MIT license.
//
// Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
// The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
//
// The MIT License in plain English: http://www.touch-code-magazine.com/JSONModel/MITLicense

#import "JSONAPI.h"

#pragma mark - static variables

static JSONAPI* sharedInstance = nil;
static long jsonRpcId = 0;

#pragma mark - JSONAPI() private interface

@interface JSONAPI ()
@property (strong, nonatomic) NSString* baseURLString;
@property (strong, nonatomic) NSString* ctype;
@end

#pragma mark - JSONAPI implementation

@implementation JSONAPI

#pragma mark - initialize

+(void)initialize
{
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        sharedInstance = [[JSONAPI alloc] init];
        sharedInstance.ctype = kContentTypeJSON;
    });
}

#pragma mark - api config methods

+(void)setAPIBaseURLWithString:(NSString*)base
{
    sharedInstance.baseURLString = base;
}

+(void)setContentType:(NSString*)ctype
{
    sharedInstance.ctype = ctype;
}

#pragma mark - GET methods

+(id)getWithPath:(NSString*)path andParams:(NSDictionary*)params error:(NSError**)err
{
    NSString* fullURL = [NSString stringWithFormat:@"%@%@", sharedInstance.baseURLString, path];
    
    id json = [JSONHTTPClient getJSONFromURLWithString: fullURL params:params error:err];
    return json;
}

+(void)getWithPath:(NSString*)path andParams:(NSDictionary*)params completion:(JSONObjectBlock)completeBlock
{
    NSString* fullURL = [NSString stringWithFormat:@"%@%@", sharedInstance.baseURLString, path];
    
    [JSONHTTPClient getJSONFromURLWithString: fullURL params:params completion:^(NSDictionary *json, JSONModelError *e) {
        completeBlock(json, e);
    }];
}

#pragma mark - POST methods

+(id)postWithPath:(NSString*)path andParams:(NSDictionary*)params error:(NSError**)err
{
    NSString* fullURL = [NSString stringWithFormat:@"%@%@", sharedInstance.baseURLString, path];
    
    id json = [JSONHTTPClient postJSONFromURLWithString: fullURL params:params error:err];
    return json;
}

+(void)postWithPath:(NSString*)path andParams:(NSDictionary*)params completion:(JSONObjectBlock)completeBlock
{
    NSString* fullURL = [NSString stringWithFormat:@"%@%@", sharedInstance.baseURLString, path];
    
    [JSONHTTPClient postJSONFromURLWithString: fullURL params:params completion:^(NSDictionary *json, JSONModelError *e) {
        completeBlock(json, e);
    }];
}

#pragma mark - RPC 1.0 methods

+(id)rpcWithMethodName:(NSString*)method andArguments:(NSArray*)args error:(NSError**)err
{
    if (!args) args = @[];
    
    NSDictionary* jsonRequest = @{
        @"id": [NSNumber numberWithLong: ++jsonRpcId],
        @"params": args,
        @"method": method
    };
    
    NSData* jsonRequestData = [NSJSONSerialization dataWithJSONObject:jsonRequest
                                                              options:kNilOptions
                                                                error:nil];
    NSString* jsonRequestString = [[NSString alloc] initWithData:jsonRequestData encoding: NSUTF8StringEncoding];
    
    id json = [JSONHTTPClient postJSONFromURLWithString: sharedInstance.baseURLString
                                             bodyString: jsonRequestString
                                                  error: err];
    return json;
}

+(void)rpcWithMethodName:(NSString*)method andArguments:(NSArray*)args completion:(JSONObjectBlock)completeBlock
{
    if (!args) args = @[];
    
    NSDictionary* jsonRequest = @{
    @"id": [NSNumber numberWithLong: ++jsonRpcId],
    @"params": args,
    @"method": method
    };
    
    NSData* jsonRequestData = [NSJSONSerialization dataWithJSONObject:jsonRequest
                                                              options:kNilOptions
                                                                error:nil];
    NSString* jsonRequestString = [[NSString alloc] initWithData:jsonRequestData encoding: NSUTF8StringEncoding];
    
    [JSONHTTPClient postJSONFromURLWithString: sharedInstance.baseURLString
                                   bodyString: jsonRequestString
                                   completion:^(NSDictionary *json, JSONModelError* e) {
                                       //
                                       NSDictionary* result = json[@"result"];
                                       completeBlock(result, e);
                                   }];
}

@end
