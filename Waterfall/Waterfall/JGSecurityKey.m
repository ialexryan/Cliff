//
//  JGSecurityKey.m
//  JGSecurity
//
//  Created by Jaden Geller on 7/30/14.
//  Copyright (c) 2014 Jaden Geller. All rights reserved.
//

#import "JGSecurityKey.h"
#import <Security/Security.h>

#define JGSecurityKeyPairGetPrivateIdentifier(x) ([(x) stringByAppendingString:@"-private"])
#define JGSecurityKeyPairGetPublicIdentifier(x) ([(x) stringByAppendingString:@"-public"])

#define kSecPaddingByteSize 11

@interface JGSecurityKey ()

@property (nonatomic) SecKeyRef keyRef;

@end

@implementation JGSecurityKey

-(instancetype)initWithSecKey:(SecKeyRef)keyRef{
    if (self = [super init]) {
        _keyRef = keyRef;
    }
    return self;
}

-(void)dealloc{
    CFRelease(_keyRef);
}

+(instancetype)keyFromKeychainWithIdentifier:(NSString*)identifier{
    
    NSMutableDictionary *query = [NSMutableDictionary dictionary];
    
    query[(__bridge id)kSecClass] = (__bridge id)kSecClassKey;
    query[(__bridge id)kSecAttrKeyType] = (__bridge id)kSecAttrKeyTypeRSA;
    query[(__bridge id)kSecAttrApplicationTag] = identifier;
    query[(__bridge id)kSecMatchLimit] = (__bridge id)kSecMatchLimitOne;
    query[(__bridge id)kSecReturnRef] = (__bridge id)kCFBooleanTrue;
    
    SecKeyRef key;
    OSStatus status = SecItemCopyMatching((__bridge CFDictionaryRef)(query), (CFTypeRef*)&key);
    
    JGSecurityKey *returnKey = nil;
    if (status == errSecSuccess) returnKey = [[self alloc]initWithSecKey:key];
    else NSLog(@"Failed to load key with identifier \"%@\" from keychain with error code %i", identifier, (int)status);
    
    return returnKey;
}

-(void)saveKeyToKeychainWithIdentifier:(NSString*)identifier{
    
    NSMutableDictionary *query = [NSMutableDictionary dictionary];
    
    // Attributes of key
    query[(__bridge id)kSecClass] = (__bridge id)kSecClassKey;
    query[(__bridge id)kSecAttrKeyType] = (__bridge id)kSecAttrKeyTypeRSA;
    query[(__bridge id)kSecAttrApplicationTag] = identifier;
    
    // Make sure we don't have any other similiar keys
    SecItemDelete((__bridge CFDictionaryRef)query); // Delete any existing keys with same identifier
    
    // Key we want to add
    query[(__bridge id)kSecValueRef] = (__bridge id)self.keyRef;
    
    OSStatus status = SecItemAdd((__bridge CFDictionaryRef)query, NULL);
    
    if (status != errSecSuccess) NSLog(@"Failed to save key with identifier \"%@\" to keychain with error code %i",identifier, (int)status);
}

+(void)deleteKeyFromKeychainWithIdentifier:(NSString*)identifier{
    NSMutableDictionary *query = [NSMutableDictionary dictionary];
    
    // Attributes of key
    query[(__bridge id)kSecClass] = (__bridge id)kSecClassKey;
    query[(__bridge id)kSecAttrKeyType] = (__bridge id)kSecAttrKeyTypeRSA;
    query[(__bridge id)kSecAttrApplicationTag] = identifier;
    query[(__bridge id)kSecReturnAttributes] = (__bridge id)kCFBooleanTrue;

    OSStatus status = SecItemDelete((__bridge CFDictionaryRef)query);
    
    if (status != errSecSuccess && status != errSecItemNotFound) NSLog(@"Failed to delete key with identifier \"%@\" from keychain with error code %i",identifier, (int)status);

}

@end

@implementation JGSecurityKeyPair : NSObject

+(instancetype)keyPairFromKeychainWithIdentifier:(NSString*)identifier{
    return [[self alloc]initWithPrivateKey:[JGPrivateSecurityKey keyFromKeychainWithIdentifier:JGSecurityKeyPairGetPrivateIdentifier(identifier)] publicKey:[JGPublicSecurityKey keyFromKeychainWithIdentifier:[identifier stringByAppendingString:JGSecurityKeyPairGetPublicIdentifier(identifier)]]];
}

-(void)saveKeyPairToKeychainWithIdentifier:(NSString*)identifier{
    [self.privateKey saveKeyToKeychainWithIdentifier:JGSecurityKeyPairGetPrivateIdentifier(identifier)];
    [self.publicKey saveKeyToKeychainWithIdentifier:JGSecurityKeyPairGetPublicIdentifier(identifier)];
}

-(instancetype)initWithPrivateKey:(JGPrivateSecurityKey*)privateKey publicKey:(JGPublicSecurityKey*)publicKey{
    if (self = [super init]) {
        _privateKey = privateKey;
        _publicKey = publicKey;
    }
    return self;
}

+(instancetype)generateSecurityKeyPair{
    return [self generateSecurityKeyPairWithSize:JGSecurityKeySize2048];
}

+(instancetype)generateSecurityKeyPairWithSize:(JGSecurityKeySize)size{
    return [self generateSecurityKeyPairWithSize:size properties:nil];
}

+(instancetype)generateSecurityKeyPairWithSize:(JGSecurityKeySize)size properties:(NSDictionary*)properties{
    
    SecKeyRef publicKeyRef;
    SecKeyRef privateKeyRef;
    
    NSMutableDictionary *mutableProperties = [NSMutableDictionary dictionaryWithDictionary:properties];
    mutableProperties[(__bridge id)kSecAttrKeyType] = (__bridge id)kSecAttrKeyTypeRSA;
    mutableProperties[(__bridge id)kSecAttrKeySizeInBits] = @(size);
    
    OSStatus status = SecKeyGeneratePair((__bridge CFDictionaryRef)mutableProperties, &publicKeyRef, &privateKeyRef);
    
    JGSecurityKeyPair *returnPair = nil;
    if (status == errSecSuccess) returnPair = [[self alloc]initWithPrivateKey:[[JGPrivateSecurityKey alloc]initWithSecKey:privateKeyRef] publicKey:[[JGPublicSecurityKey alloc]initWithSecKey:publicKeyRef]];
    else NSLog(@"Failed to generate key pair with error code %i", (int)status);
    
    return returnPair;
    
}

+(void)deleteKeyPairFromKeychainWithIdentifier:(NSString*)identifier{
    [JGSecurityKey deleteKeyFromKeychainWithIdentifier:JGSecurityKeyPairGetPublicIdentifier(identifier)];
    [JGSecurityKey deleteKeyFromKeychainWithIdentifier:JGSecurityKeyPairGetPrivateIdentifier(identifier)];
}

@end

@implementation JGPrivateSecurityKey

-(NSData*)decryptData:(NSData*)data{
    size_t bufferSize = SecKeyGetBlockSize(self.keyRef);
    uint8_t *buffer = (uint8_t*) malloc(sizeof(uint8_t) * bufferSize);
    
    OSStatus status = SecKeyDecrypt(self.keyRef, kSecPaddingPKCS1, data.bytes, data.length, buffer, &bufferSize);
    
    NSData *returnData = nil;
    if (status == errSecSuccess) returnData = [NSData dataWithBytes:buffer length:bufferSize];
    else NSLog(@"Failed to decrypt data using key %@ with error code %i", self, (int)status);
    
    free(buffer);
    return returnData;
}

-(NSData*)generateSignatureForData:(NSData*)data{
    size_t bufferSize = SecKeyGetBlockSize(self.keyRef);
    uint8_t *buffer = (uint8_t*) malloc(sizeof(uint8_t) * bufferSize);
    
    if (data.length > bufferSize - kSecPaddingByteSize){
        NSLog(@"Failed to sign data using key %@ because the data is too long for the key size", self);
        return nil;
    }
    
    OSStatus status = SecKeyRawSign(self.keyRef, kSecPaddingPKCS1, data.bytes, data.length, buffer, &bufferSize);
    
    NSData *returnData = nil;
    if (status == errSecSuccess) returnData = [NSData dataWithBytes:buffer length:bufferSize];
    else NSLog(@"Failed to sign data using key %@ with error code %i", self, (int)status);

    free(buffer);
    return returnData;
}

@end

@implementation JGPublicSecurityKey

+(instancetype)publicKeyWithBytes:(NSData*)bytes{
    
    NSMutableDictionary *query = [NSMutableDictionary dictionary];
    
    // Attributes of key
    query[(__bridge id)kSecClass] = (__bridge id)kSecClassKey;
    query[(__bridge id)kSecAttrKeyType] = (__bridge id)kSecAttrKeyTypeRSA;
    query[(__bridge id)kSecReturnRef] = (__bridge id)kCFBooleanTrue;
    query[(__bridge id)kSecAttrIsPermanent] = (__bridge id)kCFBooleanFalse;
    query[(__bridge id)kSecAttrApplicationTag] = @(bytes.hash); // Prevents duplicates
    
    // Key we want to add
    query[(__bridge id)kSecValueData] = bytes;
    
    SecKeyRef key = NULL;
    OSStatus status = SecItemAdd((__bridge CFDictionaryRef)query, (CFTypeRef*)&key);
    SecItemDelete((__bridge CFDictionaryRef)query); // We only added the key to convert it to a reference
    
    JGPublicSecurityKey *returnKey = nil;
    if (status == errSecSuccess) returnKey = [[self alloc]initWithSecKey:key];
    else NSLog(@"Failed to load key with bytes %@ with error code %i",bytes, (int)status);
    
    return returnKey;
}

-(NSData*)bytes{
    
    NSMutableDictionary *query = [NSMutableDictionary dictionary];
    
    // Attributes of key
    query[(__bridge id)kSecClass] = (__bridge id)kSecClassKey;
    query[(__bridge id)kSecAttrKeyType] = (__bridge id)kSecAttrKeyTypeRSA;
    query[(__bridge id)kSecReturnData] = (__bridge id)kCFBooleanTrue;
    query[(__bridge id)kSecReturnRef] = (__bridge id)kCFBooleanTrue;
    query[(__bridge id)kSecAttrIsPermanent] = (__bridge id)kCFBooleanFalse;
    query[(__bridge id)kSecAttrApplicationTag] = @(self.hash); // Prevents duplicates

    // Key we want to add
    query[(__bridge id)kSecValueRef] = (__bridge id)(self.keyRef);
    
    CFDictionaryRef values;
    OSStatus status = SecItemAdd((__bridge CFDictionaryRef)query, (CFTypeRef*)&values);
    SecItemDelete((__bridge CFDictionaryRef)query); // We only added the key to convert it to bytes
    
    NSData *returnData = nil;
    if (status == errSecSuccess) returnData = (__bridge NSData *)(CFDictionaryGetValue(values, kSecValueData));
    else NSLog(@"Failed to extract data from key %@ with error code %i",self, (int)status);
    
    return returnData;

}

-(NSData*)encryptData:(NSData*)data{
    size_t bufferSize = SecKeyGetBlockSize(self.keyRef);
    
    if (data.length > bufferSize - kSecPaddingByteSize){
        NSLog(@"Failed to encrypt data using key %@ because the data is too long for the key size", self);
        return nil;
    }
    
    uint8_t *buffer = (uint8_t*) malloc(sizeof(uint8_t) * bufferSize);
    
    OSStatus status = SecKeyEncrypt(self.keyRef, kSecPaddingPKCS1, data.bytes, data.length, buffer, &bufferSize);
    
    NSData *returnData = nil;
    if (status == errSecSuccess) returnData = [NSData dataWithBytes:buffer length:bufferSize];
    else NSLog(@"Failed to encrypt data using key %@ with error code %i", self, (int)status);

    free(buffer);
    return returnData;
}

-(BOOL)verifySignature:(NSData*)signature forData:(NSData*)data{
    
    OSStatus status = SecKeyRawVerify(self.keyRef, kSecPaddingPKCS1, data.bytes, data.length, signature.bytes, signature.length);
    
    return status == errSecSuccess;
}

@end