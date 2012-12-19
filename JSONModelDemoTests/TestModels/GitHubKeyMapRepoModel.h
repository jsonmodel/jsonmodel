//
//  GitHubKeyMapRepoModel.h
//  JSONModelDemo
//
//  Created by Marin Todorov on 19/12/2012.
//  Copyright (c) 2012 Underplot ltd. All rights reserved.
//

#import "JSONModel.h"

@interface GitHubKeyMapRepoModel : JSONModel

@property (strong, nonatomic) NSString* __description;
@property (strong, nonatomic) NSString* language;
@property (assign, nonatomic) NSString<Index>* name;

@end
