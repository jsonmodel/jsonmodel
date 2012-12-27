//
//  ImageModel.h
//  JSONModelDemo
//
//  Created by Marin Todorov on 02/12/2012.
//  Copyright (c) 2012 Underplot ltd. All rights reserved.
//

#import "JSONModel.h"
#import "CopyrightModel.h"

@protocol ImageModel @end

@interface ImageModel : JSONModel

@property (strong, nonatomic) NSNumber* idImage;
@property (strong, nonatomic) NSString* name;

@property (strong, nonatomic) CopyrightModel<Optional>* copyright;


@end
