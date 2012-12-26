//
//  JSONValueTransformer+UIColor.h
//  JSONModel_Demo
//
//  Created by Marin Todorov on 26/11/2012.
//  Copyright (c) 2012 Underplot ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JSONValueTransformer.h"


#ifdef __IPHONE_OS_VERSION_MAX_ALLOWED
@compatibility_alias Color UIColor;
#else
@compatibility_alias Color NSColor;
#endif

@interface JSONValueTransformer(Color)

#pragma mark - uicolor <-> hex color
/*  uicolor <-> hex color for converting text hex representations to actual color objects */

-(Color*)ColorFromNSString:(NSString*)string;
-(id)JSONObjectFromColor:(Color*)color;

@end
