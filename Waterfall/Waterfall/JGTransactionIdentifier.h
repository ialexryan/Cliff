//
//  JGTransactionIdentifier.h
//  Waterfall
//
//  Created by Alex Ryan on 8/3/14.
//  Copyright (c) 2014 Jaden Geller. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface JGTransactionIdentifier : NSObject

@property (nonatomic, readonly) NSData *data;

+(NSUInteger)byteLength;
+(JGTransactionIdentifier*)generateTransactionIdentifier;
+(JGTransactionIdentifier*)tranactionIdentifierWithData:(NSData*)data;

@end
