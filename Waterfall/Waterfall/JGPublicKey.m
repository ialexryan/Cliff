//
//  JGPublicKey.m
//  Waterfall
//
//  Created by Alex Ryan on 7/30/14.
//  Copyright (c) 2014 Jaden Geller. All rights reserved.
//

#import "JGPublicKey.h"
#define kDefaultPublicKeyDirectory @"public"

@implementation JGPublicKey

-(void)saveWithIdentity:(NSUUID*)identity{
    [self saveWithIdentity:identity directory:kDefaultPublicKeyDirectory];
}

+(instancetype)keyWithIdentity:(NSUUID*)identity{
    return [super keyWithIdentity:identity directory:kDefaultPublicKeyDirectory];
}

-(NSData*)encryptedData:(NSData*)data{
    
    size_t cipherBufferSize = SecKeyGetBlockSize(self.keyData);
    uint8_t *cipherBuffer = malloc(cipherBufferSize);
    uint8_t *nonce = (uint8_t *)[plainTextString UTF8String];
    SecKeyEncrypt(publicKey,
                  kSecPaddingOAEP,
                  nonce,
                  strlen( (char*)nonce ),
                  &cipherBuffer[0],
                  &cipherBufferSize);
    NSData *encryptedData = [NSData dataWithBytes:cipherBuffer length:cipherBufferSize];
    return [encryptedData base64EncodedString];
    
}

@end
