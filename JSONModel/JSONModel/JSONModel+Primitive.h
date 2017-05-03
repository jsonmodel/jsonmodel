//
//  JSONModel+Primitive.h
//  JSONModel
//

#import "JSONModel.h"

@interface JSONModel (Primitive)

/**
 *  For a non-primitive type object, if declaring "<Optioanl>" for it, it can be missing in the input data,
 *  But there's no 'isOptional' switch for a primitive type data, such as int, long , float, double, etc.
 *  Primitive type is always considered as a set of the required keys for the model. To solve the problem,
 *  method 'allowPrimitiveTypeAsOptioanl' is a good way to handle this problem. It take the role as the same
 *  as JSONModelClassProperty's 'isOptional' property for a primitive type.
 *  Implementing JSONModelPrimitiveProtocol in model could determine primitive type(s) is optioanal or required.
 */
- (BOOL)allowPrimitiveTypeAsOptioanl;

@end


