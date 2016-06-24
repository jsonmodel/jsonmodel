//
//  ReposModel.h
//  JSONModelDemo
//
//  Created by Marin Todorov on 19/12/2012.
//  Copyright (c) 2012 Underplot ltd. All rights reserved.
//

@import JSONModel;

@protocol GitHubRepoModel;

@interface ReposModel : JSONModel

@property (strong, nonatomic) NSMutableArray<GitHubRepoModel>* repositories;

@end

@interface ReposProtocolArrayModel : JSONModel

@property (strong, nonatomic) NSMutableArray* repositories;

@end
