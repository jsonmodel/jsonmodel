//
//  JSONCacheFile.h
//  JSONModelDemo_iOS
//
//  Created by Marin Todorov on 3/25/13.
//  Copyright (c) 2013 Underplot ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface JSONCacheFile : NSObject

@property (strong, nonatomic) NSString* fileName;
@property (assign, nonatomic) NSTimeInterval modificationTime;

@property (strong, nonatomic, readonly) NSString* key;
@property (strong, nonatomic, readonly) NSString* etag;

-(instancetype)initWithKey:(NSString*)key andEtag:(NSString*)etag;

@end