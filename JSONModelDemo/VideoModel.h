//
//  VideoModel.h
//  JSONModelDemo
//
//  Created by Marin Todorov on 02/12/2012.
//  Copyright (c) 2012 Underplot ltd. All rights reserved.
//

#import "JSONModel.h"

#import "VideoLink.h"
#import "VideoTitle.h"

@interface VideoModel : JSONModel

-(id)initWithDictionary:(NSDictionary*)d;

@property (strong, nonatomic) VideoTitle* title;
@property (strong, nonatomic) VideoLink* link;

@end
