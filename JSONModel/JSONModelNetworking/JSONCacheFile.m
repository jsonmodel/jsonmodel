//
//  JSONCacheFile.m
//  JSONModelDemo_iOS
//
//  Created by Marin Todorov on 3/25/13.
//  Copyright (c) 2013 Underplot ltd. All rights reserved.
//

#import "JSONCacheFile.h"

@implementation JSONCacheFile

-(instancetype)initWithKey:(NSString*)key andEtag:(NSString*)etag
{
    self = [super init];
    if (self!=nil) {
        if (etag!=nil) {
            self.fileName = [NSString stringWithFormat:@"%@~%@~etag",key,etag];
        } else {
            self.fileName = key;
        }
        self.modificationTime = [[NSDate date] timeIntervalSinceReferenceDate];
    }
    return self;
}

-(void)setFileName:(NSString *)fileName
{
    _fileName = fileName;
    if ([_fileName hasSuffix:@"etag"]) {
        //etag attached to object name
        NSArray* nameParts = [_fileName componentsSeparatedByString:@"~"];
        if (nameParts.count>2) {
            _etag = nameParts[nameParts.count-2];
            _key = nameParts[nameParts.count-3];
        }
    } else {
        _key = fileName;
    }
}

-(NSString*)description
{
    return [@{@"key":self.key,@"name":self.fileName,@"etag":self.etag?self.etag:@""} debugDescription];
}

@end
