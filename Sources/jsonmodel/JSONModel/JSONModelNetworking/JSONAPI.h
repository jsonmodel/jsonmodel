//
//  JSONAPI.h
//  JSONModel
//

#import <Foundation/Foundation.h>
#import "JSONHTTPClient.h"

DEPRECATED_ATTRIBUTE
@interface JSONAPI : NSObject

+ (void)setAPIBaseURLWithString:(NSString *)base DEPRECATED_ATTRIBUTE;
+ (void)setContentType:(NSString *)ctype DEPRECATED_ATTRIBUTE;
+ (void)getWithPath:(NSString *)path andParams:(NSDictionary *)params completion:(JSONObjectBlock)completeBlock DEPRECATED_ATTRIBUTE;
+ (void)postWithPath:(NSString *)path andParams:(NSDictionary *)params completion:(JSONObjectBlock)completeBlock DEPRECATED_ATTRIBUTE;
+ (void)rpcWithMethodName:(NSString *)method andArguments:(NSArray *)args completion:(JSONObjectBlock)completeBlock DEPRECATED_ATTRIBUTE;
+ (void)rpc2WithMethodName:(NSString *)method andParams:(id)params completion:(JSONObjectBlock)completeBlock DEPRECATED_ATTRIBUTE;

@end
