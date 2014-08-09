//
//  JGPeerVerifier.m
//  Waterfall
//
//  Created by Alex Ryan on 8/2/14.
//  Copyright (c) 2014 Jaden Geller. All rights reserved.
//

#import "JGPeerCommunicator.h"
#import "JGPeerKeychain.h"
#import <Security/Security.h>
#import "JGSecurityKey.h"
#import "JGPeerMessage.h"

#define kCliffServiceKey @"98FE13EF-0596-4654-998F-FF3E1E207941"

@implementation JGPeerCommunicator

+(instancetype)peerCommunicatorWithKeychain:(JGPeerKeychain*)keychain{
    return [[self alloc]initWithKeychain:keychain];
}

-(instancetype)initWithKeychain:(JGPeerKeychain*)keychain{
    if (self = [super init]) {
        _keychain = keychain;
    }
    return self;
}

-(void)setEnabled:(BOOL)enabled{
    _enabled = enabled;
    [self updateState];
}

-(void)updateState{
    // Override in subclasses
}

-(void)sendData:(NSData*)data toTrustedPeer:(NSUUID*)trustedPeer encrypted:(BOOL)encrypted{
    // Override in subclass
}

@end

@interface JGCentralPeerCommunicator ()

@property (nonatomic, readonly) CBCentralManager *manager;
@property NSMutableDictionary *connectedPeripherals;

@end

@implementation JGCentralPeerCommunicator

-(instancetype)initWithKeychain:(JGPeerKeychain *)keychain{
    if (self = [super initWithKeychain:keychain]) {
        _manager = [[CBCentralManager alloc]initWithDelegate:self queue:nil options:@{CBCentralManagerOptionShowPowerAlertKey : @YES}];
        _connectedPeripherals = [NSMutableDictionary dictionary];
    }
    return self;
}

-(void)centralManagerDidUpdateState:(CBCentralManager *)central{
    [self updateState];
}

-(void)updateState{
    if (self.manager.state == CBCentralManagerStatePoweredOn){
        if (self.enabled) [self.manager scanForPeripheralsWithServices:@[[CBUUID UUIDWithString:kCliffServiceKey]] options:nil];
        else [self.manager stopScan];
    }
}

-(void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI{
    
    NSUUID *identity = [[NSUUID alloc]initWithUUIDString:advertisementData[CBAdvertisementDataLocalNameKey]];
    
    if ([self.keychain isTrustedWithIdentity:identity]){
        [self.connectedPeripherals setObject:identity forKey:peripheral];
        [central connectPeripheral:peripheral options:nil];
    }
}

-(void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral{
    peripheral.delegate = self;
    [peripheral discoverServices:@[[CBUUID UUIDWithString:kCliffServiceKey]]];
}

-(void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error{
    [self.delegate didDisconnectFromTrustedPeer:self.connectedPeripherals[peripheral]];
    [self.connectedPeripherals removeObjectForKey:peripheral];
}

-(void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error{
    NSLog(@"We failed to connect to a peer with error %@",error);
}

-(void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error{
    assert(peripheral.services.count == 1);
    [peripheral discoverCharacteristics:@[self.keychain.localIdentity] forService:peripheral.services[0]];
}

-(void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error{
    assert(service.characteristics.count == 1);
    [peripheral setNotifyValue:YES forCharacteristic:service.characteristics[0]];
}

-(void)peripheral:(CBPeripheral*)peripheral didUpdateNotificationStateForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error{
    if (!error) {
        [self.delegate didConnectToTrustedPeer:self.connectedPeripherals[peripheral]];
    }
    else{
        NSLog(@"Wow we suck at life we can't even subscribe to a characteristic");
    }
}

-(void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error{
#warning Might be the wrong method...

    // WE FIRST NEED TO DECRYPT AND REMOVE THE FIRST BYTE
    [self.delegate didRecieveData:characteristic.value fromTrustedPeer:<#(NSUUID *)#>]
}

//
//-(instancetype)initWithKeychain:(JGPeerKeychain*)keychain{
//    if (self = [super initWithKeychain:keychain]) {
//        _manager = [[CBCentralManager alloc]initWithDelegate:self queue:nil options:@{CBCentralManagerOptionShowPowerAlertKey : @YES}];
//        _connectedPeripherals = [NSMutableDictionary dictionary];
//    }
//    return self;
//}
//
//-(void)setShouldBeScanning:(BOOL)shouldBeScanning{
//    _shouldBeScanning = shouldBeScanning;
//    
//    [self updateScanningState];
//}
//
//-(void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral{
//    
//}
//
//-(void)searchForUnlockAuthentication{
//    self.shouldBeScanning = YES;
//}
//
//-(void)cancelAuthenticationSearch{
//    self.shouldBeScanning = NO;
//}
//

@end

@interface JGPeripheralPeerCommunicator ()

@property (nonatomic, readonly) CBPeripheralManager *manager;
@property NSMutableDictionary *connectedCentrals;
#warning It would be better if this dictionary were bi-directional

@end

@implementation JGPeripheralPeerCommunicator

-(instancetype)initWithKeychain:(JGPeerKeychain *)keychain{
    if (self = [super initWithKeychain:keychain]) {
        _manager = [[CBPeripheralManager alloc]initWithDelegate:self queue:nil];
        _connectedCentrals = [NSMutableDictionary dictionary];
    }
    return self;
}

-(void)peripheralManagerDidUpdateState:(CBPeripheralManager *)peripheral{
    [self updateState];
}

-(void)updateState{
    if (self.manager.state == CBPeripheralManagerStatePoweredOn){
        if (self.enabled) {
            
            // Add Service
            CBMutableService *service = [[CBMutableService alloc]initWithType:[CBUUID UUIDWithString:kCliffServiceKey] primary:YES];
            
            NSMutableArray *characteristics = [NSMutableArray array];
            
            for (NSUUID *trustedCentral in self.keychain.trustedPeerIdentnties) {
#warning We need to update our characteristics whenever a new device is added to trusted
                
                // Add Characteristic
                CBMutableCharacteristic *characteristic = [[CBMutableCharacteristic alloc]initWithType:[CBUUID UUIDWithNSUUID:trustedCentral] properties:CBCharacteristicPropertyRead | CBCharacteristicPropertyWrite | CBCharacteristicPropertyIndicate value:nil permissions:0];
                
                [characteristics addObject:characteristic];
            }
            [service setCharacteristics:characteristics];
            [_manager addService:service];
            
#warning Later, try to just advertise the raw NSUUID and see if that also works
            [self.manager startAdvertising:@{CBAdvertisementDataLocalNameKey : self.keychain.localIdentity.UUIDString, CBAdvertisementDataServiceUUIDsKey : @[[CBUUID UUIDWithString:kCliffServiceKey]]}];
        }
        else [self.manager stopAdvertising];
    }
}

-(void)peripheralManagerDidStartAdvertising:(CBPeripheralManager *)peripheral error:(NSError *)error{
    NSLog(@"YAY we aren't totally incompetent, we started advertising");
}

-(void)sendData:(NSData*)data toTrustedPeer:(NSUUID*)trustedPeer encrypted:(BOOL)encrypted{
    if (encrypted){
        JGPublicSecurityKey *publicKey = [self.keychain peerKeyWithIdentity:trustedPeer];
        data = [publicKey encryptData:data];
    }
    
    CBMutableCharacteristic *characteristic = [[CBMutableCharacteristic alloc]initWithType:[CBUUID UUIDWithNSUUID:trustedPeer] properties:CBCharacteristicPropertyRead | CBCharacteristicPropertyWrite | CBCharacteristicPropertyIndicate value:nil permissions:0];
#warning We probably shouldn't make this characteristic again each time we use it
    
    [self.manager updateValue:data forCharacteristic:characteristic onSubscribedCentrals:[self.connectedCentrals allKeysForObject:trustedPeer]];
}

-(void)peripheralManager:(CBPeripheralManager *)peripheral didReceiveReadRequest:(CBATTRequest *)request{
    
}

-(void)peripheralManager:(CBPeripheralManager *)peripheral didReceiveWriteRequests:(NSArray *)requests{
    
}

-(void)peripheralManager:(CBPeripheralManager *)peripheral central:(CBCentral *)central didSubscribeToCharacteristic:(CBCharacteristic *)characteristic{
    NSUUID *identity = [[NSUUID alloc]initWithUUIDString:characteristic.UUID.UUIDString];
    
    [self.connectedCentrals setObject:identity forKey:central];
    [self.delegate didConnectToTrustedPeer:identity];
}

-(void)peripheralManager:(CBPeripheralManager *)peripheral central:(CBCentral *)central didUnsubscribeFromCharacteristic:(CBCharacteristic *)characteristic{
    [self.delegate didDisconnectFromTrustedPeer:self.connectedCentrals[central]];
    [self.connectedCentrals removeObjectForKey:central];
}

//
//
//-(void)peripheralManager:(CBPeripheralManager *)peripheral didReceiveReadRequest:(CBATTRequest *)request{
//#warning MAKE SURE WE ONLY DO THIS ON NEW TRANSACTIONS CUZ NOW WE DON'T AND IT'S SHIT
//    
//}
//
//-(void)peripheralManager:(CBPeripheralManager *)peripheral didReceiveWriteRequests:(NSArray *)requests{
//    for (CBATTRequest *request in requests) {
//        NSLog(@"LOOK WHAT EFFORT WAS ASKED OF US %@",request);
//    }
//}
//
//-(void)peripheralManager:(CBPeripheralManager *)peripheral central:(CBCentral *)central didSubscribeToCharacteristic:(CBCharacteristic *)characteristic{
//    
//}
//
//-(void)didReceiveMessage:(JGMessage)message fromMac:(NSUUID*)mac{
//    
//}
//
//-(void)peripheralManager:(CBPeripheralManager *)peripheral didAddService:(CBService *)service error:(NSError *)error{
//    NSLog(@"%@",service);
//}
//
//-(void)peripheralManagerDidStartAdvertising:(CBPeripheralManager *)peripheral error:(NSError *)error{
//    NSLog(@"NOW ADVERTISING");
//}
//
//-(void)provideEncryptedPassword:(NSData*)encryptedPassword toMac:(NSUUID*)mac{
//    
//}

@end