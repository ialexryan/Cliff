//
//  AppDelegate.m
//  Waterfall
//
//  Created by Alex Ryan on 7/27/14.
//  Copyright (c) 2014 Jaden Geller. All rights reserved.
//

#import "AppDelegate.h"
#import "SSKeychain.h"

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

- (IBAction)addNewDevice:(id)sender {

    self.window.appearance = [NSAppearance appearanceNamed:NSAppearanceNameVibrantDark];
    
    [NSApp activateIgnoringOtherApps:YES];
    [self.window makeKeyAndOrderFront:sender];
    [self.window setLevel: NSFloatingWindowLevel];
}

- (void)setStoredPassword:(NSString *)password {
    [SSKeychain setPassword:password forService:@"Waterfall" account:NSUserName()];
}

- (NSString *)getStoredPassword {
    return [SSKeychain passwordForService:@"Waterfall" account:NSUserName()];
}

- (void)unlockComputer {
    NSString *password = [self getStoredPassword];
    NSString *scriptString = [NSString stringWithFormat:@"tell application \"System Events\" to keystroke \"a\" using command down\ntell application \"System Events\" to keystroke \"%@\"\ntell application \"System Events\" to keystroke return", password];
    sleep(7);
    NSAppleScript *script = [[NSAppleScript alloc] initWithSource:scriptString];
    [script executeAndReturnError:nil];
}

- (IBAction)quitPress:(id)sender {
    [[NSApplication sharedApplication]terminate:self];
}

@end
