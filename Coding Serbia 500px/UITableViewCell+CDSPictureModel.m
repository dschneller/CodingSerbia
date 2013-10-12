//
//  UITableViewCell+CDSPictureModel.m
//  Coding Serbia 500px
//
//  Created by Daniel Schneller on 13.10.13.
//  Copyright (c) 2013 codecentric AG. All rights reserved.
//

#import "UITableViewCell+CDSPictureModel.h"
#import "CDSPictureModel.h"

@implementation UITableViewCell (CDSPictureModel)

-(void)configureWithPictureModel:(CDSPictureModel *)pictureModel
{
    self.textLabel.text = [pictureModel.filepath lastPathComponent];
    self.detailTextLabel.text = [pictureModel.filesize description];
    self.imageView.image = pictureModel.thumbnail;
}

@end
