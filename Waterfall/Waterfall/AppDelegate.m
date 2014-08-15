//
//  AppDelegate.m
//  Waterfall
//
//  Created by Alex Ryan on 7/27/14.
//  Copyright (c) 2014 Jaden Geller. All rights reserved.
//

#import "AppDelegate.h"
#import "JGPeerCommunicator.h"
#import "JGPeerKeychain.h"

@interface AppDelegate ()

@property NSStatusItem *statusItem;
@property (weak) IBOutlet NSMenu *statusMenu;
@property NSWindowController *pairController;

@property (nonatomic) BOOL lockScreenVisible;
@property (nonatomic) JGCentralPeerCommunicator *communicator;

@end


@implementation AppDelegate
            
- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    // Insert code here to initialize your application
  
    // Status Bar
    _statusItem = [[NSStatusBar systemStatusBar]statusItemWithLength:NSVariableStatusItemLength];
    [_statusItem setImage:[NSImage imageNamed:@"menu_icon"]];
    [_statusItem setHighlightMode:YES];
    [_statusItem setMenu:self.statusMenu];
    
    // Notification Center
    [[[NSWorkspace sharedWorkspace] notificationCenter] addObserver: self selector: @selector(screenWakeNotification:) name: NSWorkspaceScreensDidWakeNotification object: NULL];
    [[[NSWorkspace sharedWorkspace] notificationCenter] addObserver: self selector: @selector(applicationDeactivateNotification:) name: NSWorkspaceDidDeactivateApplicationNotification object: NULL];
    [[[NSWorkspace sharedWorkspace] notificationCenter] addObserver: self selector: @selector(applicationActivateNotification:) name: NSWorkspaceDidActivateApplicationNotification object: NULL];
    
    // Keychain
    
    NSString *documentDirectory = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
    NSURL *dir = [NSURL URLWithString:[documentDirectory stringByAppendingPathComponent:@"keychain_metadata"]];

    JGPeerKeychain *keychain = [JGPeerKeychain peerKeychainWithSaveDirectory:dir];
    self.communicator = [JGCentralPeerCommunicator peerCommunicatorWithKeychain:keychain];
    self.communicator.enabled = YES;
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}

#pragma mark - Handle Locks Screen Events


-(void)applicationActivateNotification:(NSNotification*)notification{
    if ([[notification.userInfo[@"NSWorkspaceApplicationKey"]bundleIdentifier] isEqualToString:@"com.apple.loginwindow"]) {
        self.lockScreenVisible = YES;
    }
}

-(void)screenWakeNotification:(NSNotification*)notification{
    if (self.lockScreenVisible) [self lockScreenAppeared];
}

-(void)applicationDeactivateNotification:(NSNotification*)notification{
    if ([[notification.userInfo[@"NSWorkspaceApplicationKey"]bundleIdentifier] isEqualToString:@"com.apple.loginwindow"]) {
        self.lockScreenVisible = NO;
        [self lockScreenDismissed];
    }
}

-(void)lockScreenAppeared{
    self.communicator.enabled = YES;
}

-(void)lockScreenDismissed{
    self.communicator.enabled = NO;
}

#pragma mark - Setters

#pragma mark - Handle UI Events

- (IBAction)addNewDevice:(id)sender
{
    self.pairController = [[NSWindowController alloc]initWithWindowNibName:@"JGAddDeviceWindowController"];
    [NSApp activateIgnoringOtherApps:YES];
    [self.pairController.window makeKeyAndOrderFront:sender];
    [self.pairController.window setLevel: NSFloatingWindowLevel];
}

- (IBAction)quitPress:(id)sender {
    [[NSApplication sharedApplication]terminate:self];
}


@end
