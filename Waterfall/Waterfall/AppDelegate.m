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
@property CBCentralManager *manager;

@property NSMutableArray *connectedPeripherals;

@property (nonatomic) BOOL shouldBeScanning;

@property (nonatomic) BOOL lockScreenVisible;

@end

#define kCliffServiceKey @"98FE13EF-0596-4654-998F-FF3E1E207941"

@implementation AppDelegate
            
- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    // Insert code here to initialize your application
    
    // Ivars
    _connectedPeripherals = [NSMutableArray array];
    
    // Status Bar
    _statusItem = [[NSStatusBar systemStatusBar]statusItemWithLength:NSVariableStatusItemLength];
    [_statusItem setImage:[NSImage imageNamed:@"menu_icon"]];
    [_statusItem setHighlightMode:YES];
    [_statusItem setMenu:self.statusMenu];
    
    // Notification Center
    [[[NSWorkspace sharedWorkspace] notificationCenter] addObserver: self selector: @selector(screenWakeNotification:) name: NSWorkspaceScreensDidWakeNotification object: NULL];
    [[[NSWorkspace sharedWorkspace] notificationCenter] addObserver: self selector: @selector(applicationDeactivateNotification:) name: NSWorkspaceDidDeactivateApplicationNotification object: NULL];
    [[[NSWorkspace sharedWorkspace] notificationCenter] addObserver: self selector: @selector(applicationActivateNotification:) name: NSWorkspaceDidActivateApplicationNotification object: NULL];

    // Core Bluetooth
    _manager = [[CBCentralManager alloc]initWithDelegate:self queue:nil options:@{CBCentralManagerOptionShowPowerAlertKey : @YES}];

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
    self.shouldBeScanning = YES;
}

-(void)lockScreenDismissed{
    self.shouldBeScanning = NO;
}

#pragma mark - Setters

-(void)setShouldBeScanning:(BOOL)shouldBeScanning{
    _shouldBeScanning = shouldBeScanning;
    
    [self updateScanningState];
}

#pragma mark - Handle UI Events

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

#pragma mark - Core Bluetooth

-(void)updateScanningState{
    if (self.manager.state == CBCentralManagerStatePoweredOn){
        if (self.shouldBeScanning) [self.manager scanForPeripheralsWithServices:nil options:nil];
        else [self.manager stopScan];
    }
}

-(void)centralManagerDidUpdateState:(CBCentralManager *)central{
    [self updateScanningState];
}

-(void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI{
    [self.connectedPeripherals addObject:peripheral];
    [central connectPeripheral:peripheral options:nil];
}

-(void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral{
    
}


@end
