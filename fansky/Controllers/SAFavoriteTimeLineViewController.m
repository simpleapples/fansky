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
#import "SAStatus+CoreDataProperties.h"
#import "SAUser+CoreDataProperties.h"

@interface SAFavoriteTimeLineViewController ()

@property (nonatomic) NSUInteger page;

@end

@implementation SAFavoriteTimeLineViewController

static NSString *const ENTITY_NAME = @"SAStatus";
static NSUInteger FAVORITE_TIME_LINE_COUNT = 40;

- (void)getLocalData
{
    [self refreshData];
}

- (void)updateDataWithRefresh:(BOOL)refresh
{
    if (!self.timeLineList) {
        self.timeLineList = [[NSArray alloc] init];
    }
    if (!refresh) {
        self.page++;
    } else {
        self.page = 1;
    }
    void (^success)(id data) = ^(id data) {
        NSArray *originalList = (NSArray *)data;
        __block NSMutableArray *tempTimeLineList = [[NSMutableArray alloc] init];
        [originalList enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            SAStatus *status = [[SADataManager sharedManager] statusWithObject:obj localUsers:nil type:SAStatusTypeFavoriteStatus];
            [tempTimeLineList addObject:status];
        }];
        if (self.page > 1) {
            NSMutableArray *existList = [self.timeLineList mutableCopy];
            [existList addObjectsFromArray:tempTimeLineList];
            self.timeLineList = [existList copy];
        } else {
            self.timeLineList = [tempTimeLineList copy];
        }
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
