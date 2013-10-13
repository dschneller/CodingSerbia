//
//  CDSPictureModel.h
//  Coding Serbia 500px
//
//  Created by Daniel Schneller on 12.10.13.
//  Copyright (c) 2013 codecentric AG. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CDSPictureModel : NSObject

@property (nonatomic, copy) NSString* filepath;
@property (nonatomic, readonly) NSNumber* filesize;
@property (nonatomic, readonly) UIImage* thumbnail;
@property (nonatomic, readonly) UIImage* image;

- (id)initWithPath:(NSString*)path;
- (void)prepareThumbnail;

@end
