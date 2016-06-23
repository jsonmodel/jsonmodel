//
//  GitHubKeyMapRepoModel.h
//  JSONModelDemo
//
//  Created by Marin Todorov on 19/12/2012.
//  Copyright (c) 2012 Underplot ltd. All rights reserved.
//

@import JSONModel;

@interface GitHubKeyMapRepoModel : JSONModel

@property (strong, nonatomic) NSString* __description;
@property (strong, nonatomic) NSString<Optional>* language;

#pragma GCC diagnostic push
#pragma GCC diagnostic ignored "-Wdeprecated-declarations"
@property (assign, nonatomic) NSString<Index>* name;
#pragma GCC diagnostic pop

@end
