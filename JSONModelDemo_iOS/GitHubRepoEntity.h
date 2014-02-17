//
//  GitHubRepoEntity.h
//  JSONModelDemo_iOS
//
//  Created by Marin Todorov on 22/1/14.
//  Copyright (c) 2014 Underplot ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface GitHubRepoEntity : NSManagedObject

@property (nonatomic, retain) NSString * created;
@property (nonatomic, retain) NSDate * pushed;
@property (nonatomic, retain) NSNumber * watchers;
@property (nonatomic, retain) NSString * owner;
@property (nonatomic, retain) NSString * language;
@property (nonatomic, retain) NSNumber * forks;
@property (nonatomic, retain) NSNumber * size;
@property (nonatomic, retain) NSString * name;

@end
