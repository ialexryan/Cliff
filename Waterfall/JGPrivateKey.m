//
//  JGPrivateKey.m
//  Waterfall
//
//  Created by Alex Ryan on 7/30/14.
//  Copyright (c) 2014 Jaden Geller. All rights reserved.
//

#import "JGPrivateKey.h"
#define kDefaultPrivateKeyDirectory @"private"

@implementation JGPrivateKey

-(void)saveWithIdentity:(NSUUID*)identity{
    [self saveWithIdentity:identity directory:kDefaultPrivateKeyDirectory];
}

+(instancetype)keyWithIdentity:(NSUUID*)identity{
    return [super keyWithIdentity:identity directory:kDefaultPrivateKeyDirectory];
}

@end
