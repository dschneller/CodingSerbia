//
//  CDSDetailViewController.m
//  Coding Serbia 500px
//
//  Created by Daniel Schneller on 12.10.13.
//  Copyright (c) 2013 codecentric AG. All rights reserved.
//

#import "CDSDetailViewController.h"
#import "CDSPictureModel.h"

@interface CDSDetailViewController ()

@property (strong, nonatomic) IBOutlet UIImageView *imageView;

@end


@implementation CDSDetailViewController

#pragma mark - View Lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self configureView];
}

#pragma mark - Managing the detail item

- (void)setDetailItem:(id)newDetailItem
{
    if (_detailItem != newDetailItem) {
        _detailItem = newDetailItem;
        
        // Update the view.
        [self configureView];
    }
}

- (void)configureView
{
    // Update the user interface for the detail item.

    if (self.detailItem) {
        CDSPictureModel* pictureModel = self.detailItem;
        
        self.navigationItem.title = [pictureModel.filepath lastPathComponent];
        self.imageView.image = pictureModel.image;
    }
}

@end
