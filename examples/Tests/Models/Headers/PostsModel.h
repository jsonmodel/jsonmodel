//
//  PostsModel.h
//  JSONModelDemo
//
//  Created by Marin Todorov on 13/12/2012.
//  Copyright (c) 2012 Underplot ltd. All rights reserved.
//

@import JSONModel;

@protocol PostModel;

@interface PostsModel : JSONModel

@property (strong, nonatomic) NSArray<PostModel>* posts;

@end
