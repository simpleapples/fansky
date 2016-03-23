//
//  SAFavoriteTimeLineViewController.m
//  fansky
//
//  Created by Zzy on 10/18/15.
//  Copyright © 2015 Zzy. All rights reserved.
//

#import "SAFavoriteTimeLineViewController.h"
#import "SAMessageDisplayUtils.h"
#import "SADataManager+Status.h"
#import "SAAPIService.h"
#import "SAStatusViewController.h"
#import "SAUserViewController.h"
#import "SATimeLineCell.h"
#import "SAStatus.h"
#import "SAUser.h"

@interface SAFavoriteTimeLineViewController ()

@property (nonatomic) NSUInteger page;

@end

@implementation SAFavoriteTimeLineViewController

static NSUInteger FAVORITE_TIME_LINE_COUNT = 40;

- (void)getLocalData
{
    [self refreshData];
}

- (void)updateDataWithRefresh:(BOOL)refresh
{
    if (!refresh) {
        self.page++;
    } else {
        self.page = 1;
    }
    void (^success)(id data) = ^(id data) {
        NSArray *dataList = (NSArray *)data;
        [[SADataManager sharedManager] insertOrUpdateStatusWithObjects:dataList type:SAStatusTypeFavoriteStatus];
        [self.tableView reloadData];
        [SAMessageDisplayUtils dismiss];
        [self.refreshView endRefreshing];
    };
    void (^failure)(NSString *error) = ^(NSString *error) {
        [SAMessageDisplayUtils showInfoWithMessage:error];
        [self.refreshView endRefreshing];
    };
    
    if (refresh) {
        [SAMessageDisplayUtils showProgressWithMessage:@"正在刷新"];
    }
    [[SAAPIService sharedSingleton] userFavoriteTimeLineWithUserID:self.userID count:FAVORITE_TIME_LINE_COUNT page:self.page success:success failure:failure];
}

#pragma mark - SATimeLineCellDelegate

- (void)timeLineCell:(SATimeLineCell *)timeLineCell avatarImageViewTouchUp:(id)sender
{
    self.selectedUserID = timeLineCell.status.user.userID;
    [self performSegueWithIdentifier:@"FavoriteTimeLineToUserSegue" sender:nil];
}

- (void)timeLineCell:(SATimeLineCell *)timeLineCell contentURLTouchUp:(id)sender
{
    NSURL *url = timeLineCell.selectedURL;
    if ([url.host isEqualToString:@"fanfou.com"]) {
        self.selectedUserID = url.lastPathComponent;
        [self performSegueWithIdentifier:@"FavoriteTimeLineToUserSegue" sender:nil];
    } else if ([url.scheme isEqualToString:@"http"] || [url.scheme isEqualToString:@"https"]) {
        [[UIApplication sharedApplication] openURL:url];
    }
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    SAStatus *status = [self.timeLineList objectAtIndex:indexPath.row];
    self.selectedStatusID = status.statusID;
    [self performSegueWithIdentifier:@"FavoriteTimeLineToStatusSegue" sender:nil];
}

#pragma mark - ARSegmentControllerDelegate

- (NSString *)segmentTitle
{
    return @"收藏";
}

@end
