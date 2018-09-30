//
//  CustomSetterModel.m
//  Examples
//
//  Created by Dmytro Povolotskyi on 25/02/2017.
//  Copyright © 2017 JSONModel. All rights reserved.
//

#import "CustomSetterModel.h"

@implementation CustomSetterModel

- (void) setTitleWithNSString:(NSString*)titleString{
	self.title = [titleString uppercaseString];
}

- (BOOL) setSubtitleWithNSString:(NSString*)subtitleString error:(NSError**)error{
	if(subtitleString.length > 10){
		*error = [NSError errorWithDomain:@"CustomSetterModelError" code:1 userInfo:nil];
		return NO;
	}
	self.subtitle = [subtitleString uppercaseString];
	return YES;
}

@end
