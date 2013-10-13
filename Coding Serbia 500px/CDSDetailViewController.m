//
//  CDSDetailViewController.m
//  Coding Serbia 500px
//
//  Created by Daniel Schneller on 12.10.13.
//  Copyright (c) 2013 codecentric AG. All rights reserved.
//

#import "CDSDetailViewController.h"
#import "CDSPictureModel.h"

@interface CDSDetailViewController() <UIScrollViewDelegate>

@property (strong, nonatomic) IBOutlet UIImageView *imageView;
@property (strong, nonatomic) IBOutlet UIScrollView *scrollView;
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;

@end


@implementation CDSDetailViewController

#pragma mark - View Lifecycle

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self initZoom];
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    [self resetZoomScale];
    [self initZoom];
}

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Managing the detail item

- (void)setDetailItem:(id)newDetailItem
{
    if (_detailItem != newDetailItem) {
        _detailItem = newDetailItem;
        
        [self configureView];
        [self initZoom];
    }
}

- (void)imageRetrieved:(NSNotification*)notification
{
    UIImage* image = [notification userInfo][@"img"];
    [self resetZoomScale];
    [self setImage:image];
    [self initZoom];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"ImageRetrieved" object:notification.object];
}

- (void) setImage:(UIImage*)image
{
    self.imageView.image = image;
    if (image)
    {
        [self.activityIndicator stopAnimating];
    }
}

#pragma mark -  Tap Gestures

- (IBAction)tapped:(id)sender {
    BOOL hidden =self.navigationController.navigationBar.alpha < 0.5;
    __weak CDSDetailViewController* weakSelf = self;
    [UIView animateWithDuration:0.25f animations:^{
        weakSelf.navigationController.navigationBar.alpha = hidden ? 1.0 : 0.0;
    }];
}


#pragma mark - Panning and Zooming

- (void)configureView
{
    if (self.detailItem) {
        CDSPictureModel* pictureModel = self.detailItem;
        self.navigationItem.title = [[pictureModel.filepath lastPathComponent] stringByDeletingPathExtension];
        [self resetZoomScale];
        
        UIImage* image = pictureModel.image;
        if (!image)
        {
            self.imageView.image = [UIImage imageNamed:@"Dots"];
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(imageRetrieved:) name:@"ImageRetrieved" object:pictureModel];
            
        }
        else
        {
            [self setImage:image];
            [self initZoom];
        }
    }
}

- (void) initZoom {
    float minZoom = MIN(self.view.bounds.size.width / self.imageView.image.size.width,
                        self.view.bounds.size.height / self.imageView.image.size.height);
    if (minZoom > 1) return;
    self.scrollView.minimumZoomScale = minZoom;
    self.scrollView.zoomScale = minZoom;
}

- (void) resetZoomScale
{
    self.scrollView.zoomScale = 1.0;
    self.scrollView.minimumZoomScale = 1.0;
    self.scrollView.maximumZoomScale = 1.0;
    [self.view setNeedsLayout];
    [self.view layoutIfNeeded];
}

#pragma mark - Scroll View Delegate Methods

-(UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return self.imageView;
}


@end
