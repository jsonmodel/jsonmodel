//
//  JSONModelCustomSetter.h
//  JSONModel
//
//  Created by Dmytro Povolotskyi on 09/02/2017.
//  Copyright © 2017 com.jsonmodel. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface JSONModelCustomSetter : NSObject

@property ( nonatomic, readonly, strong) NSValue* value;
@property ( nonatomic, readonly, assign) BOOL withErrorOutParam;

- (instancetype)initWithValue:(NSValue*)value withErrorOutParam:(BOOL) withErrorOutParam;

@end
