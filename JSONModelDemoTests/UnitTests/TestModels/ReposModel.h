//
//  ReposModel.h
//  JSONModelDemo
//
//  Created by Marin Todorov on 19/12/2012.
//  Copyright (c) 2012 Underplot ltd. All rights reserved.
//

#import "JSONModel.h"
#import "GitHubRepoModel.h"

@interface ReposModel : JSONModel

@property (strong, nonatomic) NSMutableArray<ConvertOnDemand, GitHubRepoModel>* repositories;

@end
