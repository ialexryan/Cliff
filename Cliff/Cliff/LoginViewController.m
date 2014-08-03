//
//  ViewController.m
//  Cliff
//
//  Created by Alex Ryan on 7/27/14.
//  Copyright (c) 2014 Jaden Geller. All rights reserved.
//

#import "LoginViewController.h"
#import <LocalAuthentication/LocalAuthentication.h>

#define kCliffServiceKey @"98FE13EF-0596-4654-998F-FF3E1E207941"
#define kCliffCharacteristicKey @"ADC03A17-C62A-4826-9BE6-8126B131DE03"

@interface LoginViewController ()

@property (nonatomic) BOOL recentlyAuthenticated;
@property (nonatomic) CBPeripheralManager *manager;

@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    [[NSNotificationCenter defaultCenter]addObserverForName:@"deviceUnlockedWithAuthentication" object:nil queue:nil usingBlock:^(NSNotification *note) {
        self.recentlyAuthenticated = YES;
    }];
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(receivedUnlockRequest) name:@"receivedUnlockRequest" object:nil];
    
    _manager = [[CBPeripheralManager alloc]initWithDelegate:self queue:nil];
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

-(void)buttonPress:(UIButton*)sender{

}

#pragma mark - Core Bluetooth

-(void)peripheralManagerDidUpdateState:(CBPeripheralManager *)peripheral{
    if (peripheral.state == CBPeripheralManagerStatePoweredOn) {
        
        // Add Service
        CBUUID *service = [CBUUID UUIDWithString:kCliffServiceKey];
        [_manager addService:[[CBMutableService alloc]initWithType:service primary:YES]];
        
        // Add Characteristic
        CBMutableCharacteristic *characteristic = [[CBMutableCharacteristic alloc]initWithType:[CBUUID UUIDWithString:kCliffCharacteristicKey] properties:CBCharacteristicPropertyWrite | CBCharacteristicPropertyNotify value:nil permissions:0];
        
        [peripheral startAdvertising:@{CBAdvertisementDataServiceUUIDsKey : @[[CBUUID UUIDWithString:kCliffServiceKey]]}];
    }
    else [NSException raise:@"oh fuck" format:@"jaden can fix this"];

}

-(void)peripheralManager:(CBPeripheralManager *)peripheral didAddService:(CBService *)service error:(NSError *)error{
    NSLog(@"%@",service);
}

-(void)peripheralManagerDidStartAdvertising:(CBPeripheralManager *)peripheral error:(NSError *)error{
    
}

@end
