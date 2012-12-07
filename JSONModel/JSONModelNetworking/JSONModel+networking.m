//
//  JSONModel+networking.m
//
//  @version 0.7
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

#import "JSONModel+networking.h"
#import "JSONHTTPClient.h"

BOOL _isLoading;

@implementation JSONModel(networking)

@dynamic isLoading;

-(BOOL)isLoading
{
    return _isLoading;
}

-(void)setIsLoading:(BOOL)isLoading
{
    _isLoading = isLoading;
}

-(id)initFromURLWithString:(NSString*)urlString
{
    id jsonObject = [JSONHTTPClient getJSONFromURLWithString:urlString];
    return [self initWithDictionary:jsonObject];
}

-(id)initFromURLWithString:(NSString *)urlString completion:(JSONModelBlock)completeBlock
{
    self = [super init];
    __block id blockSelf = self;
    
    if (self) {
        //initialization
        self.isLoading = YES;
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            NSData* jsonData = [NSData dataWithContentsOfURL:
                                [NSURL URLWithString: urlString]
                                ];
            
            NSDictionary* jsonObject = nil;
            if (jsonData) {
                jsonObject = [NSJSONSerialization JSONObjectWithData:jsonData options:kNilOptions error:nil];
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                blockSelf = [self initWithDictionary:jsonObject];
                
                if (completeBlock) {
                    completeBlock(blockSelf);
                }
                
                self.isLoading = NO;
            });
        });
    }
    return self;
}

@end
