//
//  JGPeerVerifier.h
//  Waterfall
//
//  Created by Alex Ryan on 8/2/14.
//  Copyright (c) 2014 Jaden Geller. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>

#import "JGTransactionIdentifier.h"

@class JGPeerMessage, JGPeerKeychain;

@protocol JGPeerCommunicatorDelegate <NSObject>

-(void)didConnectToTrustedPeer:(NSUUID*)trustedPeer;
-(void)didDisconnectFromTrustedPeer:(NSUUID*)trustedPeer;
-(void)didRecieveData:(NSData*)data fromTrustedPeer:(NSUUID*)trustedPeer;

@end

@interface JGPeerCommunicator : NSObject

@property (nonatomic, readonly) JGPeerKeychain *keychain;
@property (nonatomic) BOOL enabled;

@property (nonatomic, weak) id<JGPeerCommunicatorDelegate> delegate;

-(void)sendData:(NSData*)data toTrustedPeer:(NSUUID*)trustedPeer encrypted:(BOOL)encrypted;
+(instancetype)peerCommunicatorWithKeychain:(JGPeerKeychain*)keychain;
-(instancetype)initWithKeychain:(JGPeerKeychain*)keychain NS_DESIGNATED_INITIALIZER;

@end

@interface JGCentralPeerCommunicator : JGPeerCommunicator <CBCentralManagerDelegate, CBPeripheralDelegate>

@end

@interface JGPeripheralPeerCommunicator : JGPeerCommunicator <CBPeripheralManagerDelegate>

@end
