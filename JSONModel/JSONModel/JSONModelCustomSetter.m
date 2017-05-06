//
//  JSONModelCustomSetter.m
//  JSONModel
//
//  Created by Dmytro Povolotskyi on 09/02/2017.
//  Copyright © 2017 com.jsonmodel. All rights reserved.
//

#import "JSONModelCustomSetter.h"
#import "JSONModel.h"

@implementation JSONModelCustomSetter

- (instancetype)initWithSelector:(SEL)selector withError:(BOOL) withError
{
    if (!(self = [super init]))
        return nil;
    
    _selector = selector;
    _withError = withError;

    return self;
}

@end

@implementation JSONModelCustomSetterBuilder

+ (JSONModelCustomSetter*) buildCustomSetterForObj:(NSObject*) object propertyName:(NSString*) property type:(NSString*) type{
    NSString *capitalizedName = [property stringByReplacingCharactersInRange:NSMakeRange(0, 1) withString:[property substringToIndex:1].uppercaseString];

    SEL setterWithError = NSSelectorFromString([NSString stringWithFormat:@"set%@With%@:error:", capitalizedName, type]);
    
    if ([object respondsToSelector:setterWithError]){
        NSString *errorDescription = nil;
        if(![self validateCustomSetterWithErrorSelector:setterWithError forObj:object errorDescription:&errorDescription]){
            @throw [NSException exceptionWithName:@"Wrong custom setter with error signature"
                                           reason:errorDescription
                                         userInfo:nil];
        }
        return [[JSONModelCustomSetter alloc] initWithSelector:setterWithError withError:YES];
    }
    
    SEL setter = NSSelectorFromString([NSString stringWithFormat:@"set%@With%@:", capitalizedName, type]);
    
    if ([object respondsToSelector:setter]){
        JMLog(@"%@: Custom setter format 'set<>With<>:' is deprecated, please use 'set<>With<>:error:' instead.", NSStringFromSelector(setter));
        return  [[JSONModelCustomSetter alloc] initWithSelector:setter withError:NO];
    }
    
    return nil;
}

+ (BOOL)validateCustomSetterWithErrorSelector:(SEL) selector forObj:(NSObject*) obj errorDescription:(NSString**)errorDescription{
    NSMethodSignature *methodSignature = [obj methodSignatureForSelector:selector];
    if(strcmp(methodSignature.methodReturnType, @encode(BOOL)) != 0){
        *errorDescription = @"Method return type should be BOOL";
        return NO;
    }
    if(strcmp([methodSignature getArgumentTypeAtIndex:3], @encode(typeof(NSError**))) != 0){
        *errorDescription = @"Second argument type should be NSError**";
        return NO;
    }
    
    return YES;
    
}


@end
