//
//  SASearchViewController.m
//  fansky
//
//  Created by Zzy on 10/27/15.
//  Copyright © 2015 Zzy. All rights reserved.
//

#import "SASearchViewController.h"
#import "SAMessageDisplayUtils.h"
#import "SAStatus+CoreDataProperties.h"
#import "SADataManager+Status.h"
#import "SAUser+CoreDataProperties.h"
#import "SADataManager+User.h"
#import "SAAPIService.h"
#import "SATimeLineCell.h"

@interface SASearchViewController () <UISearchResultsUpdating>

@property (strong, nonatomic) UISearchController *searchController;
@property (copy, nonatomic) NSString *maxID;
@property (copy, nonatomic) NSString *keyword;

@end

@implementation SASearchViewController

static NSString *const ENTITY_NAME = @"SAStatus";
static NSUInteger TIME_LINE_COUNT = 40;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self updateInterface];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [self.view endEditing:YES];
    [self.searchController setActive:NO];
    [super viewWillDisappear:animated];
}

- (void)updateInterface
{
    UISearchController *searchController = [[UISearchController alloc] initWithSearchResultsController:nil];
    searchController.searchResultsUpdater = self;
    searchController.dimsBackgroundDuringPresentation = NO;
    searchController.hidesNavigationBarDuringPresentation = NO;
    self.searchController = searchController;
    self.tableView.tableHeaderView = self.searchController.searchBar;
}

- (void)getLocalData
{
    
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
//        [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:YES];
    }

    void (^success)(id data) = ^(id data) {
        NSArray *originalList = (NSArray *)data;
        __block NSMutableArray *tempTimeLineList = [[NSMutableArray alloc] init];
        [originalList enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            SAStatus *status = [[SADataManager sharedManager] statusWithObject:obj localUsers:nil type:SAStatusTypeFavoriteStatus];
            [tempTimeLineList addObject:status];
        }];
        if (self.maxID) {
            NSMutableArray *existList = [self.timeLineList mutableCopy];
            [existList addObjectsFromArray:tempTimeLineList];
            self.timeLineList = [existList copy];
        } else {
            self.timeLineList = [tempTimeLineList copy];
        }
        if (self.timeLineList.count) {
            SAStatus *lastStatus = [self.timeLineList lastObject];
            self.maxID = lastStatus.statusID;
        }
        [self.tableView reloadData];
        [SAMessageDisplayUtils dismiss];
        [self.refreshControl endRefreshing];
    };
    void (^failure)(NSString *error) = ^(NSString *error) {
        [SAMessageDisplayUtils showErrorWithMessage:error];
    };
    
    if (refresh) {
        [SAMessageDisplayUtils showProgressWithMessage:@"正在刷新"];
    }
    [[SAAPIService sharedSingleton] searchPublicTimeLineWithKeyword:self.keyword sinceID:nil maxID:maxID count:TIME_LINE_COUNT success:success failure:failure];
}

#pragma mark - UISearchResultsUpdating

- (void)updateSearchResultsForSearchController:(UISearchController *)searchController
{
    self.keyword = searchController.searchBar.text;
    [self refreshData];
}

#pragma mark - SATimeLineCellDelegate

- (void)timeLineCell:(SATimeLineCell *)timeLineCell avatarImageViewTouchUp:(id)sender
{
    self.selectedUserID = timeLineCell.status.user.userID;
    [self performSegueWithIdentifier:@"SearchToUserSegue" sender:sender];
}

- (void)timeLineCell:(SATimeLineCell *)timeLineCell contentURLTouchUp:(id)sender
{
    NSURL *url = timeLineCell.selectedURL;
    if ([url.host isEqualToString:@"fanfou.com"]) {
        self.selectedUserID = url.lastPathComponent;
        [self performSegueWithIdentifier:@"SearchToUserSegue" sender:sender];
    } else if ([url.scheme isEqualToString:@"http"] || [url.scheme isEqualToString:@"https"]) {
        [[UIApplication sharedApplication] openURL:url];
    }
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    SAStatus *status = [self.timeLineList objectAtIndex:indexPath.row];
    self.selectedStatusID = status.statusID;
    [self performSegueWithIdentifier:@"SearchToStatusSegue" sender:nil];
}

@end
