//
//  MockNSURLConnection.h
//  JSONModelDemo_iOS
//
//  Created by Marin Todorov on 3/26/13.
//  Copyright (c) 2013 Underplot ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSURLConnection (Mock)

+(void)setNextResponse:(NSHTTPURLResponse*)response data:(NSData*)data error:(NSError*)error;
+(NSURLRequest*)lastRequest;

+(void)setResponseDelay:(int)seconds;

@end
