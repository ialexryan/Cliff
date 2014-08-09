//
//  JGPeerMessage.h
//  Waterfall
//
//  Created by Alex Ryan on 8/3/14.
//  Copyright (c) 2014 Jaden Geller. All rights reserved.
//

#import <Foundation/Foundation.h>

@class JGTransactionIdentifier;

typedef NS_ENUM(UInt32, JGInstruction){
    // Computer to phone instructions
    JGInstructionToPhoneRequestUnlock = 1,
    
    // Phone to computer instructions
    JGInstructionToComputerUnlock = 1,
};

@interface JGPeerMessage : NSObject

+(instancetype)messageWithTransactionIdentifier:(JGTransactionIdentifier*)transaction instruction:(JGInstruction)instruction;
+(instancetype)messageWithTransactionIdentifier:(JGTransactionIdentifier*)transaction instruction:(JGInstruction)instruction otherData:(NSData*)other;

@property (nonatomic, readonly) NSData *packagedData;

@property (nonatomic) JGTransactionIdentifier *transaction;
@property (nonatomic) JGInstruction instruction;
@property (nonatomic) NSData *other;

@end
