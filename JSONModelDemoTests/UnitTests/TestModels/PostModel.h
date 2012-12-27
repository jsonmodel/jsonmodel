//
//  PostModel.h
//  JSONModelDemo
//
//  Created by Marin Todorov on 13/12/2012.
//  Copyright (c) 2012 Underplot ltd. All rights reserved.
//

#import "JSONModel.h"

@protocol PostModel @end

@interface PostModel : JSONModel

@property (strong, nonatomic) NSString<Index>* id;
@property (strong, nonatomic) NSString<Optional>* name;

@end
