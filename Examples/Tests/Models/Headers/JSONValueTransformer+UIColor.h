//
//  JSONValueTransformer+UIColor.h
//  JSONModel_Demo
//
//  Created by Marin Todorov on 26/11/2012.
//  Copyright (c) 2012 Underplot ltd. All rights reserved.
//

@import Foundation;
@import JSONModel;

@interface JSONValueTransformer (UIColor)

#pragma mark - uicolor <-> hex color
/* uicolor <-> hex color for converting text hex representations to actual color objects */

#ifdef __IPHONE_OS_VERSION_MAX_ALLOWED
-(UIColor*)UIColorFromNSString:(NSString*)string;
-(id)JSONObjectFromUIColor:(UIColor*)color;
#else
-(NSColor*)UIColorFromNSString:(NSString*)string;
-(id)JSONObjectFromUIColor:(NSColor*)color;
#endif

@end
