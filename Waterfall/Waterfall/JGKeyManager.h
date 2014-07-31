//
//  JGKeyManager.h
//  Waterfall
//
//  Created by Alex Ryan on 7/29/14.
//  Copyright (c) 2014 Jaden Geller. All rights reserved.
//

#import <Foundation/Foundation.h>

@class JGPublicKey, JGPrivateKey;

@interface JGKeyManager : NSObject

@property (nonatomic, readonly) JGPublicKey *publicKey;
@property (nonatomic, readonly) JGPrivateKey *privateKey;

@property (nonatomic, readonly) NSUUID *identity;

-(JGPublicKey*)publicKeyForIdentity:(NSUUID*)identity;

+(instancetype)standardKeyManager;

@end
