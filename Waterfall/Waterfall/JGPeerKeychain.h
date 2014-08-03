//
//  JGSecurityKeychain.h
//  Waterfall
//
//  Created by Alex Ryan on 8/2/14.
//  Copyright (c) 2014 Jaden Geller. All rights reserved.
//

#import <Foundation/Foundation.h>

@class JGSecurityKeyPair, JGPublicSecurityKey;

@interface JGPeerKeychain : NSObject <NSSecureCoding>

+(instancetype)defaultPeerKeychain;
+(instancetype)peerKeychainWithSaveDirectory:(NSURL*)saveDirectory;

@property (nonatomic, readonly) NSUUID *localIdentity;
@property (nonatomic, readonly) JGSecurityKeyPair *localKeys;

@property (nonatomic, readonly) NSArray *peerIdentities;
-(JGPublicSecurityKey*)peerKeyWithIdentity:(NSUUID*)identity;

-(void)trustPeerWithIdentity:(NSUUID*)identity key:(JGPublicSecurityKey*)key;
-(void)forgetPeerWithIdentity:(NSUUID*)identity;

@end
