//
//  TimeLineViewController.m
//  fansky
//
//  Created by Zzy on 6/17/15.
//  Copyright (c) 2015 Zzy. All rights reserved.
//

#import "SATimeLineViewController.h"
#import "SADataManager+User.h"
#import "SAUser+CoreDataProperties.h"
#import "SAStatus+CoreDataProperties.h"
#import "SAPhoto.h"
#import "SAAPIService.h"
#import "SADataManager+Status.h"
#import "SAStatusViewController.h"
#import "SAUserViewController.h"
#import "SAMessageDisplayUtils.h"
#import "SATimeLineCell.h"
#import "SAComposeViewController.h"
#import <DTCoreText/DTCoreText.h>
#import <URBMediaFocusViewController/URBMediaFocusViewController.h>

@interface SATimeLineViewController () <SATimeLineCellDelegate>

@property (copy, nonatomic) NSString *maxID;
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
}

- (void)viewWillAppear:(BOOL)animated
{
    [self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:animated];
    [self.tableView setEditing:NO animated:NO];
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [SAMessageDisplayUtils dismiss];
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
    [[SADataManager sharedManager] currentTimeLineWithUserID:userID type:type limit:TIME_LINE_COUNT completeHandler:^(NSArray *result) {
        self.timeLineList = result;
        [self.tableView reloadData];
        [self refreshData];
    }];
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
    } else if (self.timeLineList.count) {
        [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:YES];
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
        [[SADataManager sharedManager] currentTimeLineWithUserID:userID type:type limit:limit completeHandler:^(NSArray *result) {
            self.timeLineList = result;
            if (self.timeLineList.count) {
                SAStatus *lastStatus = [self.timeLineList lastObject];
                self.maxID = lastStatus.statusID;
            }
            [self.tableView reloadData];
            [SAMessageDisplayUtils dismiss];
            [self.refreshControl endRefreshing];
        }];
    };
    void (^failure)(NSString *error) = ^(NSString *error) {
        if (type == SAStatusTypeTimeLine) {
            [SAMessageDisplayUtils showErrorWithMessage:error];
        } else {
            [SAMessageDisplayUtils showInfoWithMessage:error];
        }
        [self.refreshControl endRefreshing];
    };
    
    if (type == SAStatusTypeTimeLine) {
        if (refresh) {
            [self.refreshControl beginRefreshing];
        }
        [[SAAPIService sharedSingleton] timeLineWithUserID:userID sinceID:nil maxID:maxID count:TIME_LINE_COUNT success:success failure:failure];
    } else {
        if (refresh) {
            [SAMessageDisplayUtils showProgressWithMessage:@"正在刷新"];
        }
        [[SAAPIService sharedSingleton] userTimeLineWithUserID:userID sinceID:nil maxID:maxID count:TIME_LINE_COUNT success:success failure:failure];
    }
}

- (void)updateInterface
{
    [self.refreshControl addTarget:self action:@selector(refreshData) forControlEvents:UIControlEventValueChanged];
    self.clearsSelectionOnViewWillAppear = YES;
    self.tableView.tableFooterView = [UIView new];
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

- (void)timeLineCell:(SATimeLineCell *)timeLineCell contentImageViewTouchUp:(id)sender
{
    if (!self.imageViewController){
        self.imageViewController = [[URBMediaFocusViewController alloc] init];
        self.imageViewController.shouldDismissOnImageTap = YES;
    }
    NSURL *imageURL = [NSURL URLWithString:timeLineCell.status.photo.largeURL];
    [self.imageViewController showImageFromURL:imageURL fromView:self.view];
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

#pragma mark - UITableViewDelegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.timeLineList.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    SAStatus *status = [self.timeLineList objectAtIndex:indexPath.row];
    UIColor *linkColor = [UIColor colorWithRed:85 / 255.0 green:172 / 255.0 blue:238 / 255.0 alpha:1];
    
    NSDictionary *optionDictionary = @{DTDefaultFontName: @"HelveticaNeue-Light",
                                       DTDefaultFontSize: @(16),
                                       DTDefaultLinkColor: linkColor,
                                       DTDefaultLinkHighlightColor: linkColor,
                                       DTDefaultLinkDecoration: @(NO),
                                       DTDefaultLineHeightMultiplier: @(1.8)};
    NSAttributedString* attributedString = [[NSAttributedString alloc] initWithHTMLData:[status.text dataUsingEncoding:NSUnicodeStringEncoding] options:optionDictionary documentAttributes:nil];
    
    DTCoreTextLayouter *layouter = [[DTCoreTextLayouter alloc] initWithAttributedString:attributedString];
    
    CGFloat width = self.tableView.frame.size.width - 86;
    CGRect maxRect = CGRectMake(0, 0, width, CGFLOAT_HEIGHT_UNKNOWN);
    NSRange entireString = NSMakeRange(0, attributedString.length);
    DTCoreTextLayoutFrame *layoutFrame = [layouter layoutFrameWithRect:maxRect range:entireString];
    CGFloat offset = 62;
    if (status.photo.imageURL) {
        offset = width / 2 + 16 + 10 + 46;
    }
    return layoutFrame.frame.size.height + offset;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *const cellName = @"SATimeLineCell";
    if (!self.isCellRegistered) {
        [tableView registerNib:[UINib nibWithNibName:cellName bundle:nil] forCellReuseIdentifier:cellName];
        self.cellRegistered = YES;
    }
    SAStatus *status = [self.timeLineList objectAtIndex:indexPath.row];
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
        SATimeLineCell *timeLinePhotoCell = (SATimeLineCell *)cell;
        [timeLinePhotoCell loadAllImages];
    }
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}

- (NSArray<UITableViewRowAction *> *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath
{
    SAStatus *status = [self.timeLineList objectAtIndex:indexPath.row];
    UITableViewRowAction *repostAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleNormal title:@"转发" handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
        SAComposeViewController *composeViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"SAComposeViewController"];
        composeViewController.repostStatusID = status.statusID;
        [self presentViewController:composeViewController animated:YES completion:nil];
    }];
    repostAction.backgroundColor = [UIColor colorWithRed:85 / 255.0 green:172 / 255.0 blue:238 / 255.0 alpha:1];
    UITableViewRowAction *replyAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleNormal title:@"回复" handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
        SAComposeViewController *composeViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"SAComposeViewController"];
        composeViewController.replyToStatusID = status.statusID;
        [self presentViewController:composeViewController animated:YES completion:nil];
    }];
    replyAction.backgroundColor = [UIColor lightGrayColor];
    return @[repostAction, replyAction];
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    if (fabs(scrollView.contentSize.height - scrollView.frame.size.height - scrollView.contentOffset.y) < scrollView.contentSize.height * 0.3) {
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
