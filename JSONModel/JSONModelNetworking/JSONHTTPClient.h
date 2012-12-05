//
//  JSONModelHTTPClient.h
//  JSONModelDemo
//
//  Created by Marin Todorov on 04/12/2012.
//  Copyright (c) 2012 Underplot ltd. All rights reserved.
//

#import "JSONModel.h"

@interface JSONHTTPClient : JSONModel

+(id)getJSONFromURL:(NSURL*)url;
+(id)getJSONFromURLWithString:(NSString*)urlString;

@end
