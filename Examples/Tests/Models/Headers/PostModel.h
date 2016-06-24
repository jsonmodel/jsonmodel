//
//  PostModel.h
//  JSONModelDemo
//
//  Created by Marin Todorov on 13/12/2012.
//  Copyright (c) 2012 Underplot ltd. All rights reserved.
//

@import JSONModel;

@interface PostModel : JSONModel

#pragma GCC diagnostic push
#pragma GCC diagnostic ignored "-Wdeprecated-declarations"
@property (strong, nonatomic) NSString<Index>* id;
#pragma GCC diagnostic pop

@property (strong, nonatomic) NSString<Optional>* name;

@end
