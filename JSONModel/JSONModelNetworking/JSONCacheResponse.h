//
//  JSONCacheResponse.h
//  JSONModelDemo_iOS
//
//  Created by Marin Todorov on 3/25/13.
//  Copyright (c) 2013 Underplot ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface JSONCacheResponse : NSObject

@property (strong, nonatomic) id object;
@property (assign, nonatomic) BOOL mustRevalidate;
@property (assign, nonatomic) BOOL isOfflineVersion;
@property (strong, nonatomic) NSMutableDictionary* revalidateHeaders;

@end
