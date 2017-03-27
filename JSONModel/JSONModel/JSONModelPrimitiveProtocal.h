//
//  JSONModelPrimitiveProtocal.h
//  JSONModel
//

@protocol JSONModelPrimitiveProtocol <NSObject>

@required

/**
 *  Primitive type is considered as a set of the required keys for the model, but sometimes if you do not want to do so,
 *  you can implement the protocal method 'allowPrimitiveTypeOptioanl' in a model to determine whether the primitive
 *  type could be a optional or requred type. Returning 'YES' is for optional type, otherwise, 'NO' is for requred type.
 */
- (BOOL)allowPrimitiveTypeOptioanl;

@end
