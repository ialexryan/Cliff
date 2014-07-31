//
//  JGPrivateKey.h
//  Waterfall
//
//  Created by Alex Ryan on 7/30/14.
//  Copyright (c) 2014 Jaden Geller. All rights reserved.
//

#import "JGKey.h"

@interface JGPrivateKey : JGKey

-(void)saveWithIdentity:(NSUUID*)identity;
+(instancetype)keyWithIdentity:(NSUUID*)identity;

@end
