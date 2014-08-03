//
//  JGPeerVerifier.h
//  Waterfall
//
//  Created by Alex Ryan on 8/2/14.
//  Copyright (c) 2014 Jaden Geller. All rights reserved.
//

#import "JGPeerKeychain.h"

// Note: compatibility also requires us to specify an action for when it is incompatible
//       action should probably either be update app or re-add trust

/*
 HEY, I WANT ANYBODY WHO TRUSTS ME = INITIAL_SENDER TO DO AN ACTION
 SEND ACTION & INITIAL_SENDER ID
 
 HELLO, LET ME CHECK IF I TRUST THE MESSAGE I JUST GOT
 SEND ACTION & INITIAL_SENDER_ID & CHALLEGE
 
 COOL, LET ME SHOW YOU THAT YOU KNOW ME
 
 */

// LIMIT = 53 bytes
// 1: COMPATIBILITY (1) + SENDER (16) + MESSAGE (4) = 21 bytes
// 1: COMPATIBILITY (1) + SENDER (16) + MESSAGE (4) = 21 bytes
// 1: COMPATIBILITY (1) + SENDER (16) + MESSAGE (4) = 21 bytes

@interface JGPeerCommunicator : JGPeerKeychain

@end
