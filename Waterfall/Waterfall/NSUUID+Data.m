//
//  Data.m
//  Waterfall
//
//  Created by Alex Ryan on 7/30/14.
//  Copyright (c) 2014 Jaden Geller. All rights reserved.
//

#import "NSUUID+Data.h"

#define UUID_BYTE_LENGTH 16

@implementation NSUUID (Data)

-(NSData*)data{
    uuid_t bytes;
    [self getUUIDBytes:bytes];
    return [NSData dataWithBytes:bytes length:UUID_BYTE_LENGTH];
}

-(instancetype)initWithData:(NSData *)data{
    return [self initWithUUIDBytes:data.bytes];
}

@end