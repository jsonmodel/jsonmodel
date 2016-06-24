//
//  NestedModel.h
//  JSONModelDemo
//
//  Created by Marin Todorov on 02/12/2012.
//  Copyright (c) 2012 Underplot ltd. All rights reserved.
//

@import JSONModel;

@class ImageModel;
@protocol ImageModel;

@interface NestedModel : JSONModel

@property (strong, nonatomic) ImageModel* singleImage;
@property (strong, nonatomic) NSArray<ImageModel>* images;
@property (strong, nonatomic) NSDictionary<ImageModel>* imagesObject;

@end

@interface NestedModelWithoutProtocols : JSONModel

@property (strong, nonatomic) ImageModel* singleImage;
@property (strong, nonatomic) NSArray* images;
@property (strong, nonatomic) NSDictionary* imagesObject;

@end
