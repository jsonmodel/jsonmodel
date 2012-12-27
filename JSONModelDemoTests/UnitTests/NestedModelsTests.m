//
//  NestedModelsTests.m
//  JSONModelDemo
//
//  Created by Marin Todorov on 02/12/2012.
//  Copyright (c) 2012 Underplot ltd. All rights reserved.
//

#import "NestedModelsTests.h"

#import "NestedModel.h"
#import "ImageModel.h"
#import "CopyrightModel.h"

@implementation NestedModelsTests
{
    NestedModel* n;
}

-(void)setUp
{
    [super setUp];
    
    NSString* filePath = [[NSBundle bundleForClass:[JSONModel class]].resourcePath stringByAppendingPathComponent:@"nestedData.json"];
    NSString* jsonContents = [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil];
    
    NSAssert(jsonContents, @"Can't fetch test data file contents.");
    
    NSError* err;
    n = [[NestedModel alloc] initWithString: jsonContents error:&err];
    NSAssert(!err, [err localizedDescription]);
    
    NSAssert(n, @"Could not load the test data file.");
}

-(void)testNestedStructures
{
    NSAssert([n.singleImage isKindOfClass:[ImageModel class]], @"singleImage is not an ImageModel instance");
    NSAssert([n.singleImage.name isEqualToString:@"lake.jpg"], @"singleImage.name is not 'lake.jpg'");
    
    NSAssert([n.images isKindOfClass:[NSArray class]], @"images is not an NSArray");
    NSAssert([n.images[0] isKindOfClass:[ImageModel class]], @"images[0] is not an ImageModel instance");
    NSAssert([[n.images[0] name] isEqualToString:@"house.jpg"], @"images[0].name is not 'house.jpg'");
    CopyrightModel* copy = [n.images[0] copyright];
    NSAssert([copy.author isEqualToString:@"Marin Todorov"], @"images[0].name.copyright is not 'Marin Todorov'");
    
    NSAssert([n.imagesObject isKindOfClass:[NSDictionary class]], @"imagesObject is not an NSDictionary");
    ImageModel* img = n.imagesObject[@"image2"];
    NSAssert([img isKindOfClass:[ImageModel class]], @"images[image2] is not an ImageModel instance");
    NSAssert([img.name isEqualToString:@"lake.jpg"], @"imagesObject[image2].name is not 'lake.jpg'");
    
}

@end
