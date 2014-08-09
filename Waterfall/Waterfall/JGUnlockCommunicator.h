//
//  JGUnlockCommunicator.h
//  Waterfall
//
//  Created by Alex Ryan on 8/3/14.
//  Copyright (c) 2014 Jaden Geller. All rights reserved.
//

#import "JGPeerCommunicator.h"

@interface JGWaterfallCommunicator : JGCentralPeerCommunicator

+(instancetype)centralPeerCommunicatorWithKeychain:(JGPeerKeychain*)keychain;
-(void)searchForUnlockAuthentication; // request from all known phones
-(void)cancelAuthenticationSearch;

@end

@protocol JGCliffCommunicatorDelegate <NSObject>

-(void)authenticationRequestedFromMac:(NSUUID*)mac;

@end

@interface JGCliffCommunicator : JGPeripheralPeerCommunicator

@property (nonatomic, weak) id<JGCliffCommunicatorDelegate> delegate;

+(instancetype)peripheralPeerCommunicatorWithKeychain:(JGPeerKeychain*)keychain delegate:(id<JGCliffCommunicatorDelegate>)delegate;
-(void)provideEncryptedPasswordToMac:(NSUUID*)mac;

@end
