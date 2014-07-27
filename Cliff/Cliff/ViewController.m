//
//  ViewController.m
//  Cliff
//
//  Created by Alex Ryan on 7/27/14.
//  Copyright (c) 2014 Jaden Geller. All rights reserved.
//

#import "ViewController.h"
#import <LocalAuthentication/LocalAuthentication.h>

@interface ViewController ()

@property (nonatomic) BOOL recentlyAuthenticated;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    [[NSNotificationCenter defaultCenter]addObserverForName:@"deviceUnlockedWithAuthentication" object:nil queue:nil usingBlock:^(NSNotification *note) {
        self.recentlyAuthenticated = YES;
    }];
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(receivedUnlockRequest) name:@"receivedUnlockRequest" object:nil];
}

-(void)receivedUnlockRequest{
    LAContext *myContext = [[LAContext alloc] init];
    NSError *authError = nil;

    // Check to make sure the user still has TouchID
    if ([myContext canEvaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics error:&authError]) {
        
        // Skip TouchID if they unlocked recently
        if (self.recentlyAuthenticated) [self tellComputerToUnlock];
        
        // Authenticate with TouchID
        else {
            
            NSString *myLocalizedReasonString = @"Computer Name";
            
            [myContext evaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics localizedReason:myLocalizedReasonString reply:^(BOOL success, NSError *error) {
                
                if (success) [self tellComputerToUnlock];
                else [self handleTouchIDError:error];
            }];
        }
    }
    else {
        [self handleTouchIDError:authError];
    }
    
    self.recentlyAuthenticated = NO;
}

-(void)handleTouchIDError:(NSError *)errorCode {
    NSLog(@"%@", errorCode);
}

-(void)tellComputerToUnlock{
    NSLog(@"The computer is now unlocked :D");
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)buttonPress:(id)sender {
    UILocalNotification *notification = [[UILocalNotification alloc]init];
    notification.alertBody = @"Click me to unlock your computer";
    notification.fireDate = [NSDate dateWithTimeIntervalSinceNow:4];
    [[UIApplication sharedApplication] scheduleLocalNotification:notification];
}

@end
