//
//  JSONModelArray.m
//
//  @version 0.10.0
//  @author Marin Todorov, http://www.touch-code-magazine.com
//

// Copyright (c) 2012-2013 Marin Todorov, Underplot ltd.
// This code is distributed under the terms and conditions of the MIT license.
//
// Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
// The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
//
// The MIT License in plain English: http://www.touch-code-magazine.com/JSONModel/MITLicense

#import "JSONModelArray.h"
#import "JSONModel.h"

@implementation JSONModelArray
{
    NSMutableArray* _storage;
    Class _targetClass;
}

- (id)initWithArray:(NSArray *)array modelClass:(Class)cls
{
    self = [super init];
    
    if (self) {
        _storage = [NSMutableArray arrayWithArray:array];
        _targetClass = cls;
    }
    return self;
}

-(id)objectAtIndex:(NSUInteger)index
{
    id obj = _storage[index];
    if (![obj isMemberOfClass:_targetClass]) {
        NSError* err = nil;
        obj = [[_targetClass alloc] initWithDictionary:obj error:&err];
        if (obj) {
            _storage[index] = obj;
        }
    }
    return obj;
}

- (void)forwardInvocation:(NSInvocation *)anInvocation
{
    [anInvocation invokeWithTarget:_storage];
}

- (NSUInteger)count
{
    return _storage.count;
}

-(id)modelWithIndexValue:(id)indexValue
{
    if (self.count==0) return nil;
    if (![self[0] indexPropertyName]) return nil;
    
    for (JSONModel* model in self) {
        if ([[model valueForKey:model.indexPropertyName] isEqual:indexValue]) {
            return model;
        }
    }
    
    return nil;
}

#pragma mark - description
-(NSString*)description
{
    NSMutableString* res = [NSMutableString stringWithFormat:@"<JSONModelArray[%@]>\n", [_targetClass description]];
    for (id m in self) {
        [res appendString: [m description]];
        [res appendString: @",\n"];
    }
    [res appendFormat:@"\n</JSONModelArray>"];
    return res;
}

@end
