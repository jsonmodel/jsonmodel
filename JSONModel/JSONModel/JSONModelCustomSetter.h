//
//  JSONModelCustomSetter.h
//  JSONModel
//
//  Created by Dmytro Povolotskyi on 09/02/2017.
//  Copyright © 2017 com.jsonmodel. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface JSONModelCustomSetter : NSObject

@property ( nonatomic, readonly, assign) SEL selector;
@property ( nonatomic, readonly, assign) BOOL withError;

@end

@interface JSONModelCustomSetterBuilder : NSObject

+ (JSONModelCustomSetter*) buildCustomSetterForObj:(NSObject*) object propertyName:(NSString*) property type:(NSString*) type;

@end
