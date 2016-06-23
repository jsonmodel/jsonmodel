//
//  RpcRequestModel.h
//  JSONModelDemo_iOS
//
//  Created by Marin Todorov on 4/2/13.
//  Copyright (c) 2013 Underplot ltd. All rights reserved.
//

@import JSONModel;

@interface RpcRequestModel : JSONModel

@property (strong, nonatomic) NSString* id;
@property (strong, nonatomic) NSArray* params;
@property (strong, nonatomic) NSString* method;

@end
