//
//  JGKeyManager.m
//  Waterfall
//
//  Created by Alex Ryan on 7/29/14.
//  Copyright (c) 2014 Jaden Geller. All rights reserved.
//

#import "JGKeyManager.h"
#import "NSUUID+Data.h"
#import "JGPrivateKey.h"
#import "JGPublicKey.h"

#define kIdentityKey @"identity"

@interface JGKeyManager ()

@end

@implementation JGKeyManager

@synthesize identity = _identity;

+(instancetype)standardKeyManager{
    static JGKeyManager *sharedInstance;
    dispatch_once_t once;
    
    dispatch_once(&once, ^{
        sharedInstance = [[[self class] alloc]init];
        [sharedInstance restoreData];
    });
    return sharedInstance;
}

-(void)restoreData{
    [self restoreIdentity];
    [self restoreOurKeys];
    [self restoreOtherKeys];
}

-(void)restoreIdentity{
    NSData *data;
    
    // Already exists
    if ((data = [[NSUserDefaults standardUserDefaults]dataForKey:kIdentityKey])){
        _identity = [[NSUUID alloc]initWithData:data];
    }
    
    // Does not yet exist
    else{
        // Create
        _identity = [NSUUID UUID];
        
        // Save
        [[NSUserDefaults standardUserDefaults]setObject:_identity.data forKey:kIdentityKey];
    }
}

-(void)restoreOurKeys{
    _privateKey = [JGPrivateKey keyWithIdentity:self.identity];
    _publicKey = [JGPublicKey keyWithIdentity:self.identity];
    
    if (!self.publicKey && !self.privateKey) {
        // Generate
        
        SecKeyRef publicKeyRef;
        SecKeyRef privateKeyRef;
        
        SecKeyGeneratePair((__bridge CFDictionaryRef)(@{ (id)kSecAttrKeyType : (id)kSecAttrKeyTypeRSA , (id)kSecAttrKeySizeInBits : @512}), &publicKeyRef, &privateKeyRef);
        
        _privateKey = [JGPrivateKey keyWithReference:privateKeyRef];
        _publicKey = [JGPublicKey keyWithReference:publicKeyRef];
        
        [_privateKey saveWithIdentity:self.identity];
        [_publicKey saveWithIdentity:self.identity];
    }
    else if (!self.publicKey || !self.privateKey){
        [NSException raise:@"This shouldn't happen ever" format:@"They lost one key but not the other awk"];
    }
}

-(void)restoreOtherKeys{
#warning This would probably make the app more zippy
}

-(JGPublicKey*)publicKeyForIdentity:(NSUUID*)identity{
    return [JGPublicKey keyWithIdentity:identity];
}

@end
