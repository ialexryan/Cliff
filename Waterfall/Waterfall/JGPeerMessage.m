//
//  JGPeerMessage.m
//  Waterfall
//
//  Created by Alex Ryan on 8/3/14.
//  Copyright (c) 2014 Jaden Geller. All rights reserved.
//

#import "JGPeerMessage.h"
#import "JGTransactionIdentifier.h"
#import "JGSecurityKey.h"

#define CURRENT_COMPATIBILITY_IDENTIFIER 0

#define OTHER_DATA_BYTE_SIZE 64

typedef uint8_t JGCompatibilityIdentifier;

@interface JGPeerMessage ()

@property (nonatomic, readonly) JGCompatibilityIdentifier compatibility;

@end

@implementation JGPeerMessage

+(instancetype)messageWithTransactionIdentifier:(JGTransactionIdentifier*)transaction instruction:(JGInstruction)instruction{
    return [self messageWithTransactionIdentifier:transaction instruction:instruction otherData:nil];
}

+(instancetype)messageWithTransactionIdentifier:(JGTransactionIdentifier*)transaction instruction:(JGInstruction)instruction otherData:(NSData*)other{
    JGPeerMessage *message = [[self alloc]init];
    message.transaction = transaction;
    message.instruction = instruction;
    message.other = other;
    return message;
}

+(instancetype)messageWithPackagedData:(NSData*)data{
    return [[self alloc]initWithPackagedData:data];
}

-(instancetype)initWithPackagedData:(NSData*)data{
    if (self = [super init]) {
        
        NSUInteger loc = 0;
        NSUInteger size;
        
        size = sizeof(JGCompatibilityIdentifier);
        [data getBytes:&_compatibility length:size];
        loc += size;
        
        size = JGTransactionIdentifier.byteLength;
        self.transaction = [JGTransactionIdentifier tranactionIdentifierWithData:[data subdataWithRange:NSMakeRange(loc, size)]];
        loc += size;
        
        size = sizeof(JGInstruction);
        [data getBytes:&_instruction range:NSMakeRange(loc, size)];
        loc += size;
        
        size = OTHER_DATA_BYTE_SIZE;
        _other = [data subdataWithRange:NSMakeRange(loc, size)];

    }
    return self;
}


-(instancetype)init{
    if (self = [super init]) {
        _compatibility = CURRENT_COMPATIBILITY_IDENTIFIER;
    }
    return self;
}

-(void)setOther:(NSData *)other{
    if (other.length != OTHER_DATA_BYTE_SIZE) {
        [NSException raise:@"Other data is in message is invalid" format:@"Other data must be exactly %i bytes",OTHER_DATA_BYTE_SIZE];
    }
    else{
        _other = other;
    }
}

-(NSData*)packagedData{
    NSMutableData *data = [[NSMutableData alloc]initWithLength:JGSecurityKeySize768];
    [data appendBytes:&_compatibility length:sizeof(JGCompatibilityIdentifier)];
    [data appendData:self.transaction.data];
    [data appendBytes:&_instruction length:sizeof(JGInstruction)];
    [data appendData:self.other];

    return data;
}

@end
