//
//  JGAddDeviceWindowController.m
//  Waterfall
//
//  Created by Alex Ryan on 7/27/14.
//  Copyright (c) 2014 Jaden Geller. All rights reserved.
//

#import "JGAddDeviceWindowController.h"
#import "JGSecurityKey.h"

#define kCliffMultipeerServiceName @"JadenGCliffGo"

@interface JGAddDeviceWindowController ()

@property (nonatomic) MCNearbyServiceBrowser *browser;
@property (nonatomic) MCSession *session;
@property (nonatomic) MCPeerID *us;
@property (nonatomic) NSMutableArray *peers;
@property (nonatomic) MCPeerID *them;

@property (nonatomic) BOOL didSendKeySuccessfully;

@end

@implementation JGAddDeviceWindowController

- (void)windowDidLoad {
    [super windowDidLoad];
    
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
    
    // Create Our ID
    self.us = [[MCPeerID alloc]initWithDisplayName:[[NSHost currentHost] localizedName]];
    
    // Create Sessions
    //self.session = [[MCSession alloc]initWithPeer:self.peerID securityIdentity: encryptionPreference:MCEncryptionRequired];
    self.session = [[MCSession alloc]initWithPeer:self.us];
#warning We need to encrypt this shit.
    self.session.delegate = self;
    
    self.browser = [[MCNearbyServiceBrowser alloc]initWithPeer:self.us serviceType:kCliffMultipeerServiceName];
    self.browser.delegate = self;
    self.peers = [NSMutableArray array];
    [self.browser startBrowsingForPeers];
    
}

#pragma mark - Browser Delegate

-(void)browser:(MCNearbyServiceBrowser *)browser didNotStartBrowsingForPeers:(NSError *)error{
    [NSException raise:@"OH FUCK" format:@"We didn't start browsing for peers, oops"];
}

-(void)browser:(MCNearbyServiceBrowser *)browser foundPeer:(MCPeerID *)peerID withDiscoveryInfo:(NSDictionary *)info{
    [self.peers addObject:peerID];
    [self updatePeerListing];
}

-(void)browser:(MCNearbyServiceBrowser *)browser lostPeer:(MCPeerID *)peerID{
    [self.peers removeObject:peerID];
    [self updatePeerListing];
}

#pragma mark - Session Delegate

-(void)session:(MCSession *)session peer:(MCPeerID *)peerID didChangeState:(MCSessionState)state{
    if (state == MCSessionStateConnected) {
        [self.browser stopBrowsingForPeers];
        [self.peers removeAllObjects];
        self.them = peerID;
        [self setupTrust];
    }
    else if (state == MCSessionStateNotConnected) {
        if (peerID == self.them) {
            [NSException raise:@"We should probably handle this" format:@"They left us :("];
        }
    }
}

-(void)session:(MCSession *)session didReceiveData:(NSData *)data fromPeer:(MCPeerID *)peerID{
    NSDictionary *received = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    
    JGPublicSecurityKey *publicKey = [JGPublicSecurityKey publicKeyWithBytes:received[@"publicKey"]];
    [publicKey saveKeyToKeychainWithIdentifier:received[@"uuid"]];
}

-(void)session:(MCSession *)session didReceiveCertificate:(NSArray *)certificate fromPeer:(MCPeerID *)peerID certificateHandler:(void (^)(BOOL))certificateHandler{
    
}

#pragma mark - Methods

-(void)updatePeerListing{
    
}

-(void)trustPeerWithId:(MCPeerID*)peerID{
    [self.browser invitePeer:peerID toSession:self.session withContext:nil timeout:0];
}

#pragma mark - Security

-(void)setupTrust{
//    
//    [self.session sendResourceAtURL:[NSURL URLWithString:publicPath] withName:@"publicKey" toPeer:self.them withCompletionHandler:^(NSError *error) {
//        if (error) [NSException raise:@"FUCK THE WORLD" format:@"WE DIDN'T SEND THE FUCKING KEY KAY %@",error];
//        self.didSendKeySuccessfully = YES;
//    }];
#warning We should probably say who we are so multiple users can send their own private key or some shit
    
}

-(void)setDidSendKeySuccessfully:(BOOL)didSendKeySuccessfully{
    _didSendKeySuccessfully = didSendKeySuccessfully;
    [self checkIfDoneSendingAndReceiving];
}

-(void)checkIfDoneSendingAndReceiving{
    
}

@end
