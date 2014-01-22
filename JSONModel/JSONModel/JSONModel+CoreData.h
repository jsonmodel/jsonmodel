//
//  JSONModel+CoreData.h
//  JSONModelDemo_iOS
//
//  Created by Marin Todorov on 22/1/14.
//  Copyright (c) 2014 Underplot ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JSONModel.h"
#import <CoreData/CoreData.h>

@interface JSONModel(CoreData)

@end

@interface NSManagedObject(JSONModel)

+(instancetype)entityWithModel:(id<AbstractJSONModelProtocol>)model inContext:(NSManagedObjectContext*)context error:(NSError**)error;
+(instancetype)entityWithDictionary:(NSDictionary*)dictionary inContext:(NSManagedObjectContext*)context error:(NSError**)error;
-(BOOL)updateWithDictionary:(NSDictionary*)dictionary error:(NSError**)error;

@end