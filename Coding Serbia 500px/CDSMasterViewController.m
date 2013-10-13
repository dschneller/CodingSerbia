//
//  CDSMasterViewController.m
//  Coding Serbia 500px
//
//  Created by Daniel Schneller on 12.10.13.
//  Copyright (c) 2013 codecentric AG. All rights reserved.
//

#import "CDSMasterViewController.h"
#import "CDSDetailViewController.h"
#import "CDSPictureModel.h"
#import "UITableViewCell+CDSPictureModel.h"

#define FOLDER_NAME @"LocalPics"

@interface CDSMasterViewController () {
    NSMutableArray *_objects;
}
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *spinningActivityIndicator;
@end

@implementation CDSMasterViewController

#pragma mark - View Lifecycle

- (void) viewDidLoad
{
    [super viewDidLoad];

    // set left button to system provided edit button
    // that takes care of the table's edit status automatically
    self.navigationItem.leftBarButtonItem = self.editButtonItem;

    [self loadImages];

}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Data management

- (void) loadImages
{
    // because file system operations can potentially take a long time,
    // do not block the UI thread with it. Instead, dispatch that
    // task to an asynchronous working queue and continue immediately

    __weak CDSMasterViewController* weakSelf = self;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSArray* filenames = [[NSBundle mainBundle] pathsForResourcesOfType:@"jpg"
                                                                inDirectory:FOLDER_NAME];
        for (NSString* filename in filenames)
        {
                CDSPictureModel* model = [[CDSPictureModel alloc] initWithPath:filename];
                // once the model is created, update the UI. Because UI must not be
                // touched from a background queue, fire that as a task on the main
                // queue
                dispatch_async(dispatch_get_main_queue(), ^{
                    [weakSelf insertNewImage:model];
                });

        }
    });
}

- (void)insertNewImage:(CDSPictureModel*)pictureModel
{
    // lazy initialization of the array for the images
    if (!_objects) {
        _objects = [[NSMutableArray alloc] init];
    }
    u_int32_t randomIndex = arc4random_uniform((u_int32_t)[_objects count]);

    [_objects insertObject:pictureModel atIndex:randomIndex];

    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:randomIndex inSection:0];
    // as UITableViewRowAnimatioNone seems to have been broken since forever,
    // we can only disable the animations wholesale while adding a row
    [UIView setAnimationsEnabled:NO];
    [self.tableView insertRowsAtIndexPaths:@[indexPath]
                          withRowAnimation:UITableViewRowAnimationNone];
    [UIView setAnimationsEnabled:YES];
    [self.spinningActivityIndicator stopAnimating];
}

#pragma mark - Table View

- (IBAction)refresh:(id)sender {
    UIRefreshControl* r = sender;
    _objects = nil;
    [self loadImages];
    [self.tableView reloadData];
    [r endRefreshing];


}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _objects.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SubtitleCell"
                                                              forIndexPath:indexPath];
    CDSPictureModel *pictureModel = _objects[indexPath.row];
    [cell configureWithPictureModel:pictureModel];
    if (!pictureModel.thumbnail)
    {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(thumbnailDidUpdate:) name:@"ThumbnailDidUpdateNotification" object:pictureModel];
    }

    return cell;
}

- (void) thumbnailDidUpdate:(NSNotification*)notification
{
    CDSPictureModel* model = notification.object;
    NSUInteger index = [_objects indexOfObject:model];
    [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:index inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"ThumbnailDidUpdateNotification" object:model];
}

#pragma mark - Table View Editing

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    // deletion
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [_objects removeObjectAtIndex:indexPath.row];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }
}


#pragma mark - Segues

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"showDetail"]) {
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        NSDate *object = _objects[indexPath.row];
        [[segue destinationViewController] setDetailItem:object];
    }
}

@end
