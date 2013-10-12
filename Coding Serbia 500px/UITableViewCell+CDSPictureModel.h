//
//  UITableViewCell+CDSPictureModel.h
//  Coding Serbia 500px
//
//  Created by Daniel Schneller on 13.10.13.
//  Copyright (c) 2013 codecentric AG. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CDSPictureModel;

@interface UITableViewCell (CDSPictureModel)

- (void) configureWithPictureModel:(CDSPictureModel*)pictureModel;

@end
