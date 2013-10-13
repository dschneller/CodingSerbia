//
//  UIImage+CDSThumbnail.m
//  Coding Serbia 500px
//
//  Created by Daniel Schneller on 13.10.13.
//  Copyright (c) 2013 codecentric AG. All rights reserved.
//

#import "UIImage+CDSThumbnail.h"

@implementation UIImage (CDSThumbnail)

- (UIImage*) generateThumbail
{
    CGSize thumbnailSize = CGSizeMake(43, 43);
    UIGraphicsBeginImageContextWithOptions(thumbnailSize, NO, 0.0);
    [self drawInRect:CGRectMake(0, 0, thumbnailSize.width, thumbnailSize.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

@end
