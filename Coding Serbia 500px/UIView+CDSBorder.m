//
//  UIView+CDSBorder.m
//  Coding Serbia 500px
//
//  Created by Daniel Schneller on 14.10.13.
//  Copyright (c) 2013 codecentric AG. All rights reserved.
//

#import "UIView+CDSBorder.h"
#import <QuartzCore/QuartzCore.h>
#import <objc/runtime.h>


@implementation UIView (CDSBorder)

- (id)swizzled_initWithFrame:(CGRect)frame
{
    // This is the confusing part (article explains this line).
    id result = [self swizzled_initWithFrame:frame];

    // Safe guard: do we have an UIView (or something that has a layer)?
    if ([result respondsToSelector:@selector(layer)]) {
        // Get layer for this view.
        CALayer *layer = [result layer];
        // Set border on layer.
        layer.borderWidth = 2;
        layer.borderColor = [[UIColor redColor] CGColor];
    }

    // Return the modified view.
    return result;
}

- (id)swizzled_initWithCoder:(NSCoder *)aDecoder
{
    // This is the confusing part (article explains this line).
    id result = [self swizzled_initWithCoder:aDecoder];

    // Safe guard: do we have an UIView (or something that has a layer)?
    if ([result respondsToSelector:@selector(layer)]) {
        // Get layer for this view.
        CALayer *layer = [result layer];
        // Set border on layer.
        layer.borderWidth = 2;
        layer.borderColor = [[UIColor blueColor] CGColor];
    }

    // Return the modified view.
    return result;
}

+ (void)load
{
    // The "+ load" method is called once, very early in the application life-cycle.
    // It's called even before the "main" function is called. Beware: there's no
    // autorelease pool at this point, so avoid Objective-C calls.
    Method original, swizzle;

    // Get the "- (id)initWithFrame:" method.
    original = class_getInstanceMethod(self, @selector(initWithFrame:));
    // Get the "- (id)swizzled_initWithFrame:" method.
    swizzle = class_getInstanceMethod(self, @selector(swizzled_initWithFrame:));
    // Swap their implementations.
    method_exchangeImplementations(original, swizzle);

    // Get the "- (id)initWithCoder:" method.
    original = class_getInstanceMethod(self, @selector(initWithCoder:));
    // Get the "- (id)swizzled_initWithCoder:" method.
    swizzle = class_getInstanceMethod(self, @selector(swizzled_initWithCoder:));
    // Swap their implementations.
    method_exchangeImplementations(original, swizzle);
}

@end
