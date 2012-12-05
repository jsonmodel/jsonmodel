//
//  JSONModel+networking.h
//  JSONModelDemo
//
//  Created by Marin Todorov on 04/12/2012.
//  Copyright (c) 2012 Underplot ltd. All rights reserved.
//

#import "JSONModel.h"
#import "JSONHTTPClient.h"

@interface JSONModel(networking)

-(id)initFromURLWithString:(NSString*)urlString;

@end
