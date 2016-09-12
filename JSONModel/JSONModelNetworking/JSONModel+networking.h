//
//  JSONModel+networking.h
//  JSONModel
//

#import "JSONModel.h"
#import "JSONHTTPClient.h"

typedef void (^JSONModelBlock)(id model, JSONModelError *err) DEPRECATED_ATTRIBUTE;

@interface JSONModel (Networking)

@property (assign, nonatomic) BOOL isLoading DEPRECATED_ATTRIBUTE;
- (instancetype)initFromURLWithString:(NSString *)urlString completion:(JSONModelBlock)completeBlock DEPRECATED_ATTRIBUTE;
+ (void)getModelFromURLWithString:(NSString *)urlString completion:(JSONModelBlock)completeBlock DEPRECATED_ATTRIBUTE;
+ (void)postModel:(JSONModel *)post toURLWithString:(NSString *)urlString completion:(JSONModelBlock)completeBlock DEPRECATED_ATTRIBUTE;

@end
