//
//  UITableViewCell+CDSPictureModel.m
//  Coding Serbia 500px
//
//  Created by Daniel Schneller on 13.10.13.
//  Copyright (c) 2013 codecentric AG. All rights reserved.
//

#import "UITableViewCell+CDSPictureModel.h"
#import "NSNumber+CDSHumanReadable.h"
#import "CDSPictureModel.h"

@implementation UITableViewCell (CDSPictureModel)

-(void)configureWithPictureModel:(CDSPictureModel *)pictureModel
{
    self.textLabel.text = [pictureModel.filepath lastPathComponent];

    UIImage* thumbnail = pictureModel.thumbnail;
    if (thumbnail)
    {
        self.imageView.image = thumbnail;
        NSString* exposure = [self formatExposureTime:pictureModel.exposureTime];
        NSString* shotDate = [self formatShotDate:pictureModel.shotDate];

        NSString* detailinfo = [NSString stringWithFormat:@"%@ - %@ - %@ - %@px", [pictureModel.filesize humanReadableFilesize], exposure, shotDate, pictureModel.resolution];
        self.detailTextLabel.text = detailinfo;
    } else {
        self.imageView.image = [UIImage imageNamed:@"Dots"];
        self.detailTextLabel.text = @"...";
   }
}

- (NSString*) formatExposureTime:(CGFloat)exposureTime
{
    NSString* exposure;
    if (exposureTime == 0) {
        exposure = @"Exp. unkn.";
    } else if (exposureTime >= 1.0) {
        exposure = [NSString stringWithFormat:@"%0.01fs", exposureTime];
    } else {
        exposure = [NSString stringWithFormat:@"1/%0.fs", 1/exposureTime];
    }
    return exposure;
}

- (NSString*) formatShotDate:(NSDate*)date
{
    NSDateFormatter* f = [[NSDateFormatter alloc] init] ;
    [f setDateStyle:NSDateFormatterShortStyle];
    [f setTimeStyle:NSDateFormatterNoStyle];
    NSString* shotDate = [f stringFromDate:date];
    shotDate = shotDate ?: @"No Date";
    return shotDate;
}

@end
