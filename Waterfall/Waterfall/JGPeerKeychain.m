//
//  JGSecurityKeychain.m
//  Waterfall
//
//  Created by Alex Ryan on 8/2/14.
//  Copyright (c) 2014 Jaden Geller. All rights reserved.
//

#import "JGPeerKeychain.h"
#import "JGSecurityKey.h"

#define KeychainIdentifierWithIdentity(x) ([(x.UUIDString) stringByAppendingString:@"-peer"])

@interface JGPeerKeychain ()

@property (nonatomic) NSMutableDictionary *peers;
@property (nonatomic) NSURL *saveDirectory;

@end

@implementation JGPeerKeychain

-(instancetype)initWithCoder:(NSCoder *)aDecoder{
    if (self = [super init]) {
        _localIdentity = [aDecoder decodeObjectOfClass:[NSUUID class] forKey:@"localIdentity"];
        NSArray *peerIdentities = [aDecoder decodeObjectOfClass:[NSArray class] forKey:@"peerIdentities"];
        
        // We need to get the local key and peer keys, and create the peer dictionary
        _localKeys = [JGSecurityKeyPair keyPairFromKeychainWithIdentifier:KeychainIdentifierWithIdentity(_localIdentity)];
        _peers = [NSMutableDictionary dictionary];
        for (NSUUID *peer in peerIdentities) {
            _peers[peer] = [JGPublicSecurityKey keyFromKeychainWithIdentifier:KeychainIdentifierWithIdentity(peer)];
        }
    }
    return self;
}

-(void)encodeWithCoder:(NSCoder *)aCoder{
    [aCoder encodeObject:_localIdentity forKey:@"localIdentity"];
    [aCoder encodeObject:_peers.allKeys forKey:@"peerIdentities"];
}

+(BOOL)supportsSecureCoding{
    return YES;
}

-(void)save{
    [[NSKeyedArchiver archivedDataWithRootObject:self] writeToURL:self.saveDirectory atomically:YES];
}

+(instancetype)peerKeychainWithSaveDirectory:(NSURL*)saveDirectory{
    
    NSData *loadedData;
    
    if (loadedData) {
        JGPeerKeychain *keychain = [NSKeyedUnarchiver unarchiveObjectWithData:loadedData];
        keychain.saveDirectory = saveDirectory;
        return keychain;
    }
    else{
        return [[self alloc]initWithSaveDirectory:saveDirectory];
    }
}

-(id)initWithSaveDirectory:(NSURL*)saveDirectory{
    if (self = [super init]) {
        _saveDirectory = saveDirectory;
        _localIdentity = [NSUUID UUID];
        _localKeys = [JGSecurityKeyPair generateSecurityKeyPairWithSize:JGSecurityKeySize512];
        _peers = [NSMutableDictionary dictionary];
        
        if (saveDirectory){
            [_localKeys saveKeyPairToKeychainWithIdentifier:KeychainIdentifierWithIdentity(_localIdentity)];
            [self save];
        }
    }
    return self;
}

-(id)init{
    return [self initWithSaveDirectory:nil];
}

-(NSArray*)trustedPeerIdentnties{
    return self.peers.allKeys;
}

-(JGPublicSecurityKey*)peerKeyWithIdentity:(NSUUID*)identity{
    return (JGPublicSecurityKey*)self.peers[identity];
}

-(BOOL)isTrustedWithIdentity:(NSUUID*)identity{
    return [self.peers objectForKey:identity] != nil;
}
-(void)trustPeerWithIdentity:(NSUUID*)identity key:(JGPublicSecurityKey*)key{
    [self.peers setObject:key forKey:identity];

    if (self.saveDirectory){
        [key saveKeyToKeychainWithIdentifier:KeychainIdentifierWithIdentity(identity)];
        [self save];
    }
}

-(void)forgetPeerWithIdentity:(NSUUID*)identity{
    [self.peers removeObjectForKey:identity];
    
    if (self.saveDirectory) {
        [JGSecurityKey deleteKeyFromKeychainWithIdentifier:KeychainIdentifierWithIdentity(identity)];
        [self save];
    }
}

@end
