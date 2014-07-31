//
//  Data.h
//  Waterfall
//
//  Created by Alex Ryan on 7/30/14.
//  Copyright (c) 2014 Jaden Geller. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSUUID (Data)

@property (nonatomic, readonly) NSData *data;
-(instancetype)initWithData:(NSData*)data;

@end