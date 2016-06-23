//
//  GitHubRepoModelForUSMapper.h
//  JSONModelDemo
//
//  Created by Marin Todorov on 21/12/2012.
//  Copyright (c) 2012 Underplot ltd. All rights reserved.
//

@import JSONModel;

@interface GitHubRepoModelForUSMapper : JSONModel

@property (strong, nonatomic) NSDate* pushedAt;
@property (strong, nonatomic) NSDate* createdAt;
@property (assign, nonatomic) int aVeryLongPropertyName;
@property (strong, nonatomic) NSString* itemObject145;
@property (strong, nonatomic) NSString<Optional>* itemObject176Details;

@end
