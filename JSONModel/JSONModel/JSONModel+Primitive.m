//
//  JSONModel+Primitive.m
//  JSONModel
//

#import "JSONModel+Primitive.h"
#import "JSONModelPrimitiveProtocal.h"

@implementation JSONModel (Primitive)

- (BOOL)allowPrimitiveTypeAsOptioanl {
    if ([self respondsToSelector:@selector(allowPrimitiveTypeOptioanl)]) {
        return [(JSONModel<JSONModelPrimitiveProtocol>*)self allowPrimitiveTypeOptioanl];
    }
    return NO;
}

@end
