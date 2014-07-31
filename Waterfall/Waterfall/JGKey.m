//
//  JGKey.m
//  Waterfall
//
//  Created by Alex Ryan on 7/29/14.
//  Copyright (c) 2014 Jaden Geller. All rights reserved.
//

#import "JGKey.h"

@implementation JGKey

+(instancetype)keyWithReference:(SecKeyRef)reference{
    return [[JGKey alloc]initWithReference:reference];
}

+(instancetype)keyWithIdentity:(NSUUID*)identity directory:(NSString*)directory{
    return [[JGKey alloc]initWithIdentity:identity directory:directory];
}

-(instancetype)initWithReference:(SecKeyRef)reference{
    return [self initWithData:[NSData dataWithBytes:reference length:SecKeyGetBlockSize(reference)]];
}

-(instancetype)initWithIdentity:(NSUUID*)identity directory:(NSString*)directory{
    return [self initWithData:[[NSFileManager defaultManager] contentsAtPath:[self.class pathForIdentity:identity directory:directory]]];
}

-(instancetype)initWithData:(NSData*)data{
    if (self = [super init]) {
        _keyData = data;
    }
    return self;
}

-(void)saveWithIdentity:(NSUUID*)identity directory:(NSString*)directory{
#warning Saving to the document directory is insecure
    [self.keyData writeToFile:[self.class pathForIdentity:identity directory:directory] atomically:YES];
}

+(NSString*)pathForIdentity:(NSUUID*)identity directory:(NSString*)directory{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentDirectory = paths[0];
    return [documentDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@/%@",directory, identity.UUIDString]];
}

@end
