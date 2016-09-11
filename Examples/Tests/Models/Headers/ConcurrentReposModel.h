//
//  ConcurrentReposModel.h
//  Examples
//
//  Created by robin on 9/8/16.
//  Copyright © 2016 JSONModel. All rights reserved.
//

@import JSONModel;

@interface ConcurrentModel : JSONModel
// Same as GitHubRepoModel. Concurrent testing need a model that not run test yet.

@property (strong, nonatomic) NSDate* created;
@property (strong, nonatomic) NSDate* pushed;
@property (assign, nonatomic) int watchers;
@property (strong, nonatomic) NSString* owner;
@property (assign, nonatomic) int forks;
@property (strong, nonatomic) NSString<Optional>* language;
@property (assign, nonatomic) BOOL fork;
@property (assign, nonatomic) double size;
@property (assign, nonatomic) int followers;

#pragma GCC diagnostic push
#pragma GCC diagnostic ignored "-Wdeprecated-declarations"
@property (strong, nonatomic) NSString<Index>* name;
#pragma GCC diagnostic pop

@end

@protocol ConcurrentModel;

@interface ConcurrentReposModel : JSONModel

@property (strong, nonatomic) NSMutableArray<ConcurrentModel>* repositories;

@end