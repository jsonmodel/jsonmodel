//
//  JSONValueTransformer+UIColor.m
//  JSONModel_Demo
//
//  Created by Marin Todorov on 26/11/2012.
//  Copyright (c) 2012 Underplot ltd. All rights reserved.
//

#import "JSONValueTransformer+UIColor.h"

@implementation JSONValueTransformer (UIColor)

#ifdef __IPHONE_OS_VERSION_MAX_ALLOWED
-(UIColor*)UIColorFromNSString:(NSString *)string
#else
-(NSColor*)NSColorFromNSString:(NSString *)string
#endif
{
	//
	// http://stackoverflow.com/a/13648705
	//

	NSString *noHashString = [string stringByReplacingOccurrencesOfString:@"#" withString:@""]; // remove the #
	NSScanner *scanner = [NSScanner scannerWithString:noHashString];
	[scanner setCharactersToBeSkipped:[NSCharacterSet symbolCharacterSet]]; // remove + and $

	unsigned hex;
	if (![scanner scanHexInt:&hex]) return nil;
	int r = (hex >> 16) & 0xFF;
	int g = (hex >> 8) & 0xFF;
	int b = (hex) & 0xFF;

#ifdef __IPHONE_OS_VERSION_MAX_ALLOWED
	return [UIColor colorWithRed:r / 255.0f green:g / 255.0f blue:b / 255.0f alpha:1.0f];
#else
	return [NSColor colorWithCalibratedRed:r / 255.0f green:g / 255.0f blue:b / 255.0f alpha:1.0f];
#endif
}

#ifdef __IPHONE_OS_VERSION_MAX_ALLOWED
-(id)JSONObjectFromUIColor:(UIColor*)color
#else
-(id)JSONObjectFromNSColor:(NSColor*)color
#endif
{
	//
	// http://softteco.blogspot.de/2011/06/extract-hex-rgb-color-from-uicolor.mtml
	//

	return [NSString stringWithFormat:@"#%02X%02X%02X", (int)((CGColorGetComponents(color.CGColor))[0]*255.0), (int)((CGColorGetComponents(color.CGColor))[1]*255.0), (int)((CGColorGetComponents(color.CGColor))[2]*255.0)];
}

@end
