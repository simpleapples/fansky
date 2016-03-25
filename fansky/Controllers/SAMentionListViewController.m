//
//  SAMentionListViewController.m
//  fansky
//
//  Created by Zzy on 9/18/15.
//  Copyright © 2015 Zzy. All rights reserved.
//

#import "SAMentionListViewController.h"
#import "SADataManager+User.h"
#import "SAUser+CoreDataProperties.h"
#import "SAStatusViewController.h"
#import "SADataManager+Status.h"
#import "SAMessageDisplayUtils.h"
#import "SAStatus+CoreDataProperties.h"
#import "SAAPIService.h"
#import "SAUserViewController.h"
#import "SATimeLineCell.h"

@interface SAMentionListViewController ()

@property (copy, nonatomic) NSString *maxID;

@end

@implementation SAMentionListViewController

static NSString *const ENTITY_NAME = @"SAStatus";
static NSUInteger TIME_LINE_COUNT = 40;

- (void)getLocalData
{
    SAUser *currentUser = [SADataManager sharedManager].currentUser;
    [[SADataManager sharedManager] currentMentionTimeLineWithUserID:currentUser.userID offset:0 limit:TIME_LINE_COUNT completeHandler:^(NSArray *result) {
        self.timeLineList = result;
        [self.tableView reloadData];
        [self refreshData];
    }];
}

- (void)updateDataWithRefresh:(BOOL)refresh
{
    NSString *maxID;
    if (!refresh) {
        maxID = self.maxID;
    } else if (self.timeLineList.count) {
        [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:YES];
    }
    NSString *userID = [SADataManager sharedManager].currentUser.userID;
    void (^success)(id data) = ^(id data) {
        [[SADataManager sharedManager] insertOrUpdateStatusWithObjects:data type:SAStatusTypeMentionStatus];
        NSUInteger offset = self.timeLineList.count;
        if (refresh) {
            offset = 0;
        }
        [[SADataManager sharedManager] currentMentionTimeLineWithUserID:userID offset:offset limit:TIME_LINE_COUNT completeHandler:^(NSArray *result) {
            if (refresh) {
                self.timeLineList = result;
            } else {
                self.timeLineList = [self.timeLineList arrayByAddingObjectsFromArray:result];
            }
            if (self.timeLineList.count) {
                SAStatus *lastStatus = [self.timeLineList lastObject];
                self.maxID = lastStatus.statusID;
            }
            [self.tableView reloadData];
            [self.refreshView endRefreshing];
        }];
    };
    void (^failure)(NSString *error) = ^(NSString *error) {
        [SAMessageDisplayUtils showErrorWithMessage:error];
        [self.refreshView endRefreshing];
    };

    if (refresh) {
        [self.refreshView triggerAnimated:YES];
    }
    [[SAAPIService sharedSingleton] mentionStatusWithSinceID:nil maxID:maxID count:TIME_LINE_COUNT success:success failure:failure];
}

#pragma mark - SATimeLineCellDelegate

- (void)timeLineCell:(SATimeLineCell *)timeLineCell avatarImageViewTouchUp:(id)sender
{
    self.selectedUserID = timeLineCell.status.user.userID;
    [self performSegueWithIdentifier:@"MentionListToUserSegue" sender:nil];
}

- (void)timeLineCell:(SATimeLineCell *)timeLineCell contentURLTouchUp:(id)sender
{
    NSURL *url = timeLineCell.selectedURL;
    if ([url.host isEqualToString:@"fanfou.com"]) {
        self.selectedUserID = url.lastPathComponent;
        [self performSegueWithIdentifier:@"MentionListToUserSegue" sender:nil];
    } else if ([url.scheme isEqualToString:@"http"] || [url.scheme isEqualToString:@"https"]) {
        [[UIApplication sharedApplication] openURL:url];
    }
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    SAStatus *status = [self.timeLineList objectAtIndex:indexPath.row];
    self.selectedStatusID = status.statusID;
    [self performSegueWithIdentifier:@"MentionListToStatusSegue" sender:nil];
}

@end
