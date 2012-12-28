//
//  AppDelegate.m
//  JSONModelOSX
//
//  Created by Marin Todorov on 25/12/2012.
//  Copyright (c) 2012 Underplot ltd. All rights reserved.
//

#import "AppDelegate.h"
#import "ViewController.h"

@interface AppDelegate()
@property (strong, nonatomic) ViewController* controller;
@end


@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    // Insert code here to initialize your application
    
    self.controller = [[ViewController alloc] initWithNibName:@"ViewController" bundle:nil];
    self.window.contentView = self.controller.view;
    
    self.controller.view.frame = ((NSView*)self.window.contentView).bounds;
    self.controller.view.autoresizingMask = NSViewWidthSizable |  NSViewHeightSizable;
    
}

- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)theApplication {
    return YES;
}

@end
