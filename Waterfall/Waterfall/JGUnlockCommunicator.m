//
//  JGUnlockCommunicator.m
//  Waterfall
//
//  Created by Alex Ryan on 8/3/14.
//  Copyright (c) 2014 Jaden Geller. All rights reserved.
//

#import "JGUnlockCommunicator.h"

@implementation JGWaterfallCommunicator

-(void)unlockComputerWithEncryptedPassword:(NSData*)encryptedPassword{
    NSData *data = [self.keychain.localKeys.privateKey decryptData:encryptedPassword];
#warning We should use a C API for encrypting and decrypting this shit, maybe?
    
    CFStringRef password = CFStringCreateWithBytes(NULL, data.bytes, data.length, kCFStringEncodingUTF8, false);
    
    CFIndex length = CFStringGetLength(password);
    for (CFIndex i = 0; i < length; i++)
    {
        unichar currentchar = CFStringGetCharacterAtIndex(password, i);
        CGEventRef event = CGEventCreateKeyboardEvent(NULL, 0, true);
        CGEventKeyboardSetUnicodeString(event, 1, &currentchar);
        CGEventPost(kCGHIDEventTap, event);
    }
    
    CGEventRef enterKey = CGEventCreateKeyboardEvent(NULL, 36, true);
    CGEventPost(kCGHIDEventTap, enterKey);
}

@end

@implementation JGCliffCommunicator



@end