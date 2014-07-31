//
//  JGKey.h
//  Waterfall
//
//  Created by Alex Ryan on 7/29/14.
//  Copyright (c) 2014 Jaden Geller. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface JGKey : NSObject

@property (nonatomic, readonly) NSData *keyData;

+(instancetype)keyWithReference:(SecKeyRef)reference;
+(instancetype)keyWithIdentity:(NSUUID*)identity directory:(NSString*)directory;
-(void)saveWithIdentity:(NSUUID*)identity directory:(NSString*)directory;

@end
