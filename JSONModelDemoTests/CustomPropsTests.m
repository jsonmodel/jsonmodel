//
//  CustomPropsTests.m
//  JSONModelDemo
//
//  Created by Marin Todorov on 02/12/2012.
//  Copyright (c) 2012 Underplot ltd. All rights reserved.
//

#import "CustomPropsTests.h"
#import "CustomPropertyModel.h"

@implementation CustomPropsTests
{
    CustomPropertyModel* c;
}

-(void)setUp
{
    [super setUp];
    
    NSString* filePath = [[NSBundle mainBundle].resourcePath stringByAppendingPathComponent:@"colors.json"];
    NSString* jsonContents = [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil];
    
    NSAssert(jsonContents, @"Can't fetch test data file contents.");
    
    @try {
        c = [[CustomPropertyModel alloc] initWithString: jsonContents];
    }
    @catch (NSException* e1) {
        NSAssert1(NO, @"%@", [e1 debugDescription]);
    }
    
    
    NSAssert(c, @"Could not load the test data file.");
}

-(void)testColors
{
    NSAssert([c.redColor isKindOfClass:[UIColor class]], @"redColor is not a UIColor instance");
    NSLog(@"red : %@", c.redColor);
    NSAssert(CGColorEqualToColor(c.redColor.CGColor, [UIColor redColor].CGColor), @"redColor's value is not red color");
}


@end
