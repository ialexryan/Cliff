//
//  JGTransactionIdentifier.m
//  Waterfall
//
//  Created by Alex Ryan on 8/3/14.
//  Copyright (c) 2014 Jaden Geller. All rights reserved.
//

#import "JGTransactionIdentifier.h"
#define TRANSACTION_IDENTIFIER_BYTE_SIZE 16

@implementation JGTransactionIdentifier

+(NSUInteger)byteLength{
    return TRANSACTION_IDENTIFIER_BYTE_SIZE;
}

+(JGTransactionIdentifier*)generateTransactionIdentifier{
    uint8_t * identifier = malloc(sizeof(uint8_t) * [self byteLength]);
    if (SecRandomCopyBytes(kSecRandomDefault, [self byteLength], identifier) == -1){
        [NSException raise:@"Random number generation failed" format:@"Unable to generate random transaction identifier"];
    }
    NSData *data = [NSData dataWithBytes:identifier length:[self byteLength]];
    free(identifier);
    
    return [JGTransactionIdentifier tranactionIdentifierWithData:data];
}

+(JGTransactionIdentifier*)tranactionIdentifierWithData:(NSData*)data{
    return [[self alloc]initWithData:data.bytes];
}

-(instancetype)initWithData:(NSData*)data{
    if (self = [super init]) {
        _data = data;
    }
    return self;
}

@end
