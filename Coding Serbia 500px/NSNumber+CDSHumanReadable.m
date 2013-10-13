//
//  NSNumber+CDSHumanReadable.m
//  Coding Serbia 500px
//
//  Created by Daniel Schneller on 13.10.13.
//  Copyright (c) 2013 codecentric AG. All rights reserved.
//

#import "NSNumber+CDSHumanReadable.h"

@implementation NSNumber (CDSHumanReadable)

- (NSString*)humanReadableFilesize
{
    NSByteCountFormatter* formatter = [[NSByteCountFormatter alloc] init];
    return [formatter stringFromByteCount:[self longLongValue]];
}

@end
