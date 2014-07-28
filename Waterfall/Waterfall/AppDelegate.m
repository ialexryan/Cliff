//
//  AppDelegate.m
//  Waterfall
//
//  Created by Alex Ryan on 7/27/14.
//  Copyright (c) 2014 Jaden Geller. All rights reserved.
//

#import "AppDelegate.h"

@interface AppDelegate ()

@property (weak) IBOutlet NSWindow *window;
@property NSStatusItem *statusItem;
@property (weak) IBOutlet NSMenu *statusMenu;

@end

@implementation AppDelegate
            
- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    // Insert code here to initialize your application
    
    _statusItem = [[NSStatusBar systemStatusBar]statusItemWithLength:NSVariableStatusItemLength];
    [_statusItem setImage:[NSImage imageNamed:@"menu_icon"]];
    [_statusItem setHighlightMode:YES];
    [_statusItem setMenu:self.statusMenu];

}


- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}

- (IBAction)addNewDevice:(id)sender
{
    
    [NSApp activateIgnoringOtherApps:YES];
    [self.window makeKeyAndOrderFront:sender];
    [self.window setLevel: NSFloatingWindowLevel];
}

- (IBAction)quitPress:(id)sender {
    [[NSApplication sharedApplication]terminate:self];
}

@end
