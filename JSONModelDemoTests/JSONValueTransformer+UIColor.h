//
//  JSONValueTransformer+UIColor.h
//  JSONModel_Demo
//
//  Created by Marin Todorov on 26/11/2012.
//  Copyright (c) 2012 Underplot ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JSONValueTransformer.h"

@interface JSONValueTransformer(UIColor)

#pragma mark - uicolor <-> hex color
/*  uicolor <-> hex color for converting text hex representations to actual color objects */

-(UIColor*)UIColorFromNSString:(NSString*)string;
-(id)JSONObjectFromUIColor:(UIColor*)color;

@end
