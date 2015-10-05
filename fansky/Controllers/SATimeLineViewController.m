//
//  TimeLineViewController.m
//  fansky
//
//  Created by Zzy on 6/17/15.
//  Copyright (c) 2015 Zzy. All rights reserved.
//

#import "SATimeLineViewController.h"
#import "SADataManager+User.h"
#import "SATimeLineCell.h"
#import "SAUser+CoreDataProperties.h"
#import "SAStatus+CoreDataProperties.h"
#import "SAPhoto.h"
#import "SAAPIService.h"
#import "SADataManager+Status.h"
#import "SAStatusViewController.h"
#import "SAUserViewController.h"
#import "SAMessageDisplayUtils.h"
#import "SATimeLinePhotoCell.h"
#import <URBMediaFocusViewController/URBMediaFocusViewController.h>

@interface SATimeLineViewController () <SATimeLineCellDelegate, SATimeLinePhotoCellDelegate>

@property (strong, nonatomic) NSArray *timeLineList;
@property (copy, nonatomic) NSString *maxID;
@property (copy, nonatomic) NSString *selectedStatusID;
@property (copy, nonatomic) NSString *selectedUserID;
@property (nonatomic, getter = isCellRegistered) BOOL cellRegistered;
@property (strong, nonatomic) URBMediaFocusViewController *imageViewController;

@end

@implementation SATimeLineViewController

static NSString *const ENTITY_NAME = @"SAStatus";
static NSUInteger TIME_LINE_COUNT = 40;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self updateInterface];
    
    [self getLocalData];
    
    [self refreshData];
}

- (void)getLocalData
{
    NSString *userID = self.userID;
    SAStatusTypes type = SAStatusTypeUserStatus;
    if (!userID) {
        SAUser *currentUser = [SADataManager sharedManager].currentUser;
        userID = currentUser.userID;
        type = SAStatusTypeTimeLine;
    }
    self.timeLineList = [[SADataManager sharedManager] currentTimeLineWithUserID:userID type:type limit:TIME_LINE_COUNT];
    [self.tableView reloadData];
}

- (void)refreshData
{
    [self updateDataWithRefresh:YES];
}

- (void)updateDataWithRefresh:(BOOL)refresh
{
    if (!self.timeLineList) {
        self.timeLineList = [[NSArray alloc] init];
    }
    NSString *maxID;
    if (!refresh) {
        maxID = self.maxID;
    }
    NSString *userID = self.userID;
    SAStatusTypes type = SAStatusTypeUserStatus;
    if (!userID) {
        SAUser *currentUser = [SADataManager sharedManager].currentUser;
        userID = currentUser.userID;
        type = SAStatusTypeTimeLine;
    }
    void (^success)(id data) = ^(id data) {
        [[SADataManager sharedManager] insertOrUpdateStatusWithObjects:data type:type];
        NSUInteger limit = TIME_LINE_COUNT;
        if (!refresh) {
            limit = self.timeLineList.count + TIME_LINE_COUNT;
        }
        self.timeLineList = [[SADataManager sharedManager] currentTimeLineWithUserID:userID type:type limit:limit];
        if (self.timeLineList.count) {
            SAStatus *lastStatus = [self.timeLineList lastObject];
            self.maxID = lastStatus.statusID;
        }
        [self.tableView reloadData];
        [self.refreshControl endRefreshing];
    };
    void (^failure)(NSString *error) = ^(NSString *error) {
        [SAMessageDisplayUtils showErrorWithMessage:error];
        [self.refreshControl endRefreshing];
    };
    
    if (!self.userID) {
        [[SAAPIService sharedSingleton] timeLineWithUserID:userID sinceID:nil maxID:maxID count:TIME_LINE_COUNT success:success failure:failure];
    } else {
        [[SAAPIService sharedSingleton] userTimeLineWithUserID:userID sinceID:nil maxID:maxID count:TIME_LINE_COUNT success:success failure:failure];
    }
}

- (void)updateInterface
{
    [self.refreshControl addTarget:self action:@selector(refreshData) forControlEvents:UIControlEventValueChanged];
    self.clearsSelectionOnViewWillAppear = YES;
    self.tableView.tableFooterView = [UIView new];
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = 140;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.destinationViewController isKindOfClass:[SAStatusViewController class]]) {
        SAStatusViewController *statusViewController = (SAStatusViewController *)segue.destinationViewController;
        statusViewController.statusID = self.selectedStatusID;
    } else if ([segue.destinationViewController isKindOfClass:[SAUserViewController class]]) {
        SAUserViewController *userViewController = (SAUserViewController *)segue.destinationViewController;
        userViewController.userID = self.selectedUserID;
    }
}

#pragma mark - SATimeLineCellDelegate

- (void)timeLineCell:(SATimeLineCell *)timeLineCell avatarImageViewTouchUp:(id)sender
{
    self.selectedUserID = timeLineCell.status.user.userID;
    [self performSegueWithIdentifier:@"TimeLineToUserSegue" sender:nil];
}

- (void)timeLineCell:(SATimeLineCell *)timeLineCell contentURLTouchUp:(id)sender
{
    NSURL *url = timeLineCell.selectedURL;
    if ([url.host isEqualToString:@"fanfou.com"]) {
        self.selectedUserID = url.lastPathComponent;
        [self performSegueWithIdentifier:@"TimeLineToUserSegue" sender:nil];
    } else if ([url.scheme isEqualToString:@"http"] || [url.scheme isEqualToString:@"https"]) {
        [[UIApplication sharedApplication] openURL:url];
    }
}

#pragma mark - SATimeLinePhotoCellDelegate

- (void)timeLinePhotoCell:(SATimeLinePhotoCell *)timeLineCell avatarImageViewTouchUp:(id)sender
{
    self.selectedUserID = timeLineCell.status.user.userID;
    [self performSegueWithIdentifier:@"TimeLineToUserSegue" sender:nil];
}

- (void)timeLinePhotoCell:(SATimeLinePhotoCell *)timeLineCell contentImageViewTouchUp:(id)sender
{
    if (!self.imageViewController){
        self.imageViewController = [[URBMediaFocusViewController alloc] init];
    }
    NSURL *imageURL = [NSURL URLWithString:timeLineCell.status.photo.largeURL];
    [self.imageViewController showImageFromURL:imageURL fromView:self.view];
}

- (void)timeLinePhotoCell:(SATimeLinePhotoCell *)timeLineCell contentURLTouchUp:(id)sender
{
    NSURL *url = timeLineCell.selectedURL;
    if ([url.host isEqualToString:@"fanfou.com"]) {
        self.selectedUserID = url.lastPathComponent;
        [self performSegueWithIdentifier:@"TimeLineToUserSegue" sender:nil];
    } else if ([url.scheme isEqualToString:@"http"] || [url.scheme isEqualToString:@"https"]) {
        [[UIApplication sharedApplication] openURL:url];
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.timeLineList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *const cellName = @"SATimeLineCell";
    static NSString *const photoCellName = @"SATimeLinePhotoCell";
    if (!self.isCellRegistered) {
        [tableView registerNib:[UINib nibWithNibName:cellName bundle:nil] forCellReuseIdentifier:cellName];
        [tableView registerNib:[UINib nibWithNibName:photoCellName bundle:nil] forCellReuseIdentifier:photoCellName];
        self.cellRegistered = YES;
    }
    SAStatus *status = [self.timeLineList objectAtIndex:indexPath.row];
    if (status.photo.imageURL) {
        SATimeLinePhotoCell *cell = [tableView dequeueReusableCellWithIdentifier:photoCellName forIndexPath:indexPath];
        [cell configWithStatus:status];
        cell.delegate = self;
        return cell;
    }
    SATimeLineCell *cell = [tableView dequeueReusableCellWithIdentifier:cellName forIndexPath:indexPath];
    [cell configWithStatus:status];
    cell.delegate = self;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    SAStatus *status = [self.timeLineList objectAtIndex:indexPath.row];
    self.selectedStatusID = status.statusID;
    [self performSegueWithIdentifier:@"TimeLineToStatusSegue" sender:nil];
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([cell isKindOfClass:[SATimeLineCell class]]) {
        SATimeLineCell *timeLineCell = (SATimeLineCell *)cell;
        [timeLineCell loadAllImages];
    } else if ([cell isKindOfClass:[SATimeLinePhotoCell class]]) {
        SATimeLinePhotoCell *timeLinePhotoCell = (SATimeLinePhotoCell *)cell;
        [timeLinePhotoCell loadAllImages];
    }
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    if (fabs(scrollView.contentSize.height - scrollView.frame.size.height - scrollView.contentOffset.y) < 1.f) {
        [self updateDataWithRefresh:NO];
    }
}

#pragma mark - ARSegmentControllerDelegate

- (NSString *)segmentTitle
{
    return @"时间线";
}

- (UIScrollView *)streachScrollView
{
    return self.tableView;
}

@end
