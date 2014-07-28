//
//  AppDelegate.m
//  Waterfall
//
//  Created by Alex Ryan on 7/27/14.
//  Copyright (c) 2014 Jaden Geller. All rights reserved.
//

#import "AppDelegate.h"

@interface AppDelegate ()

@property NSStatusItem *statusItem;
@property (weak) IBOutlet NSMenu *statusMenu;
@property NSWindowController *pairController;

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
    self.pairController = [[NSWindowController alloc]initWithWindowNibName:@"JGAddDeviceWindowController"];
    [NSApp activateIgnoringOtherApps:YES];
    [self.pairController.window makeKeyAndOrderFront:sender];
    [self.pairController.window setLevel: NSFloatingWindowLevel];
    
    NSLog(@"%@",[[NSHost currentHost] localizedName]);
    
}

- (IBAction)quitPress:(id)sender {
    [[NSApplication sharedApplication]terminate:self];
}

@end
