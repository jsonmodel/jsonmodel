//
//  ImmutableModel.h
//  JSONModelDemo_OSX
//
//  Created by Vaňo Jakub on 15/07/15.
//  Copyright (c) 2015 Underplot ltd. All rights reserved.
//

#import "JSONModel.h"

@interface ImmutableModel : JSONModel <DoNotIgnoreReadonlyProperties>

- (instancetype)initWithRequired:(NSString*)required
                        optional:(NSString*)optional
                          ignore:(NSString*)ignore;

@property(strong, nonatomic, readonly) NSString*           readonlyRequired;
@property(strong, nonatomic, readonly) NSString<Optional>* readonlyOptional;
@property(strong, nonatomic, readonly) NSString<Ignore>*   readonlyIgnore;

@end
