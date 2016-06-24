//
//  GitHubRepoModel.h
//  JSONModelDemo
//
//  Created by Marin Todorov on 19/12/2012.
//  Copyright (c) 2012 Underplot ltd. All rights reserved.
//

@import JSONModel;

@interface GitHubRepoModel : JSONModel

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
