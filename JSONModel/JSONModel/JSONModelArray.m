//
//  JSONModelArray.m
//
//  @version 1.2
//  @author Marin Todorov (http://www.underplot.com) and contributors
//

// Copyright (c) 2012-2015 Marin Todorov, Underplot ltd.
// This code is distributed under the terms and conditions of the MIT license.
//
// Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
// The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
//

#import "JSONModelArray.h"
#import "JSONModel.h"

@implementation JSONModelArray
{
    NSMutableArray *_storage;
    Class _targetClass;
}

- (id)initWithArray:(NSArray *)array modelClass:(Class)cls
{
    if (!(self = [super init])) return nil;

    _storage = [NSMutableArray arrayWithArray:array];
    _targetClass = cls;

    return self;
}

- (NSUInteger)count
{
    return _storage.count;
}

- (id)objectAtIndex:(NSUInteger)index
{
    id object = _storage[index];

    if (![object isMemberOfClass:_targetClass])
    {
        object = [[_targetClass alloc] initWithDictionary:object error:nil];
        if (object) _storage[index] = object;
    }

    return object;
}

- (id)modelWithIndexValue:(id)indexValue
{
    if (self.count == 0) return nil;
    if (![_storage[0] indexPropertyName]) return nil;

    for (JSONModel *model in _storage)
    {
        if ([[model valueForKey:model.indexPropertyName] isEqual:indexValue])
        {
            return model;
        }
    }
    
    return nil;
}

@end
