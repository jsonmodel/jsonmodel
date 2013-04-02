//
//  MTTestSemaphor
//
//  @version 0.1
//  @author Marin Todorov, http://www.touch-code-magazine.com
//

// Copyright (c) 2012 Marin Todorov, Underplot ltd.
// This code is distributed under the terms and conditions of the MIT license.
//
// Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
// The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

#import "MTTestSemaphor.h"

@implementation MTTestSemaphor
{
    NSMutableDictionary* flags;
}

+(instancetype)semaphore
{   
    static MTTestSemaphor *sharedInstance = nil;
    static dispatch_once_t once;
    
    dispatch_once(&once, ^{
        sharedInstance = [MTTestSemaphor alloc];
        sharedInstance = [sharedInstance _initPrivate];
    });
    
    return sharedInstance;
}

-(id)_initPrivate
{
    self = [super init];
    if (self != nil) {
        @synchronized (flags) {
            flags = [NSMutableDictionary dictionaryWithCapacity:10];
        }
    }
    return self;
}

-(BOOL)isLifted:(NSString*)key
{
    @synchronized (flags) {
        NSLog(@"check key: %@", key);
        NSLog(@"key value: %@", flags[key]);
        return [flags objectForKey:key]!=nil;
    }
}

-(void)lift:(NSString*)key
{
    @synchronized (flags) {
        [flags setObject:@"YES" forKey: key];
    }
}

-(void)waitForKey:(NSString*)key
{
    NSLog(@"begin flags '%@' : %@", key, flags);
    
    BOOL keepRunning = YES;
    while (keepRunning && [[NSRunLoop currentRunLoop] runMode: NSDefaultRunLoopMode beforeDate:[NSDate dateWithTimeIntervalSinceNow:1.0]]) {
        keepRunning = ![[MTTestSemaphor semaphore] isLifted: key];
    }
    NSLog(@"end flags '%@': %@",key, flags);

}

@end
