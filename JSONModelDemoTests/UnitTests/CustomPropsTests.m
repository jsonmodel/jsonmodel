//
//  CustomPropsTests.m
//  JSONModelDemo
//
//  Created by Marin Todorov on 02/12/2012.
//  Copyright (c) 2012 Underplot ltd. All rights reserved.
//

#import "CustomPropsTests.h"
#import "CustomPropertyModel.h"

#import "QuartzCore/QuartzCore.h"

@implementation CustomPropsTests
{
    CustomPropertyModel* c;
}

-(void)setUp
{
    [super setUp];
    
    NSString* filePath = [[NSBundle bundleForClass:[JSONModel class]].resourcePath stringByAppendingPathComponent:@"colors.json"];
    NSString* jsonContents = [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil];
    
    NSAssert(jsonContents, @"Can't fetch test data file contents.");
    
    NSError* err;
    c = [[CustomPropertyModel alloc] initWithString: jsonContents error:&err];
    NSAssert(!err, [err localizedDescription]);
    
    NSAssert(c, @"Could not load the test data file.");
}

-(void)testColors
{
#ifdef __IPHONE_OS_VERSION_MAX_ALLOWED
    NSAssert([c.redColor isKindOfClass:[UIColor class]], @"redColor is not a Color instance");
    CGColorRef redColor = [UIColor redColor].CGColor;
#else
    NSAssert([c.redColor isKindOfClass:[NSColor class]], @"redColor is not a Color instance");
    CGColorRef redColor = [NSColor redColor].CGColor;
#endif

    NSAssert(CGColorEqualToColor(c.redColor.CGColor, redColor), @"redColor's value is not red color");
}


@end
