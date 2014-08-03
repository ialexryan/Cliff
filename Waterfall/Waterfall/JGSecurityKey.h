//
//  JGSecurityKey.h
//  JGSecurity
//
//  Created by Jaden Geller on 7/30/14.
//  Copyright (c) 2014 Jaden Geller. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
    JGSecurityKeySize512 = 512,
    JGSecurityKeySize768 = 768,
    JGSecurityKeySize1024 = 1024,
    JGSecurityKeySize2048 = 2048
} JGSecurityKeySize;

@class JGPublicSecurityKey, JGPrivateSecurityKey;

@interface JGSecurityKeyPair : NSObject

@property (nonatomic, readonly) JGPrivateSecurityKey *privateKey;
@property (nonatomic, readonly) JGPublicSecurityKey *publicKey;

+(instancetype)generateSecurityKeyPair;
+(instancetype)generateSecurityKeyPairWithSize:(JGSecurityKeySize)size;
+(instancetype)generateSecurityKeyPairWithSize:(JGSecurityKeySize)size properties:(NSDictionary*)properties;

+(instancetype)keyPairFromKeychainWithIdentifier:(NSString*)identifier;
-(void)saveKeyPairToKeychainWithIdentifier:(NSString*)identifier;

+(void)deleteKeyPairFromKeychainWithIdentifier:(NSString*)identifier;

@end

@interface JGSecurityKey : NSObject

+(instancetype)keyFromKeychainWithIdentifier:(NSString*)identifier;
-(void)saveKeyToKeychainWithIdentifier:(NSString*)identifier;

+(void)deleteKeyFromKeychainWithIdentifier:(NSString*)identifier;

@end

@interface JGPrivateSecurityKey : JGSecurityKey

-(NSData*)decryptData:(NSData*)data;
-(NSData*)generateSignatureForData:(NSData*)data;

@end

@interface JGPublicSecurityKey : JGSecurityKey

@property (nonatomic, readonly) NSData *bytes;

+(instancetype)publicKeyWithBytes:(NSData*)bytes;

-(NSData*)encryptData:(NSData*)data;
-(BOOL)verifySignature:(NSData*)signature forData:(NSData*)data;

@end