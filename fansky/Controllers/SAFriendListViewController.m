//
//  SAFriendListViewController.m
//  fansky
//
//  Created by Zzy on 9/25/15.
//  Copyright © 2015 Zzy. All rights reserved.
//

#import "SAFriendListViewController.h"
#import "SAMessageDisplayUtils.h"
#import "SAAPIService.h"
#import "SAFriend.h"
#import "SAFriendCell.h"
#import "SAUserViewController.h"

@interface SAFriendListViewController () <UIActionSheetDelegate>

@property (strong, nonatomic) NSArray *friendList;
@property (nonatomic) NSUInteger page;
@property (copy, nonatomic) NSString *selectedUserID;
@property (nonatomic, getter = isCellRegistered) BOOL cellRegistered;

@end

@implementation SAFriendListViewController

static NSUInteger FRIEND_LIST_COUNT = 30;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self updateInterface];
    
    [self refreshData];
}

- (void)viewWillAppear:(BOOL)animated
{
    [self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:animated];
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [SAMessageDisplayUtils dismiss];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)updateInterface
{
    if (self.type == SAFriendListTypeFollow) {
        self.title = @"关注者";
    } else if (self.type == SAFriendListTypeFriend) {
        self.title = @"关注";
    } else if (self.type == SAFriendListTypeRequest) {
        self.title = @"关注请求";
    }
    [self.refreshControl addTarget:self action:@selector(refreshData) forControlEvents:UIControlEventValueChanged];
    self.clearsSelectionOnViewWillAppear = YES;
    self.tableView.tableFooterView = [UIView new];
    self.tableView.rowHeight = 70;
}

- (void)refreshData
{
    [self updateDataWithRefresh:YES];
}

- (void)updateDataWithRefresh:(BOOL)refresh
{
    if (!refresh) {
        self.page++;
    } else {
        [self.refreshControl beginRefreshing];
        self.page = 1;
    }
    
    void (^success)(id data) = ^(id data) {
        NSMutableArray *tempFriendList = [[NSMutableArray alloc] init];
        NSArray *originalList = (NSArray *)data;
        [originalList enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            SAFriend *friend = [[SAFriend alloc] initWithObject:obj];
            [tempFriendList addObject:friend];
        }];
        if (self.page <= 1) {
            self.friendList = tempFriendList;
        } else {
            self.friendList = [self.friendList arrayByAddingObjectsFromArray:tempFriendList];
        }
        [self.tableView reloadData];
        [self.refreshControl endRefreshing];
        [SAMessageDisplayUtils dismiss];
    };
    void (^failure)(NSString *error) = ^(NSString *error) {
        [SAMessageDisplayUtils showErrorWithMessage:error];
        [self.refreshControl endRefreshing];
    };

    if (self.type == SAFriendListTypeFollow) {
        [[SAAPIService sharedSingleton] userFollowersWithUserID:self.userID count:FRIEND_LIST_COUNT page:self.page success:success failure:failure];
    } else if (self.type == SAFriendListTypeFriend) {
        [[SAAPIService sharedSingleton] userFriendsWithUserID:self.userID count:FRIEND_LIST_COUNT page:self.page success:success failure:failure];
    } else if (self.type == SAFriendListTypeRequest) {
        [[SAAPIService sharedSingleton] userFriendshipRequestWithCount:FRIEND_LIST_COUNT page:self.page success:success failure:failure];
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.destinationViewController isKindOfClass:[SAUserViewController class]]) {
        SAUserViewController *userViewController = (SAUserViewController *)segue.destinationViewController;
        userViewController.userID = self.selectedUserID;
    }
}

- (NSArray *)friendList
{
    if (!_friendList) {
        _friendList = [[NSArray alloc] init];
    }
    return _friendList;
}

#pragma mark - UITableViewDelegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.friendList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *const cellName = @"SAFriendCell";
    SAFriend *friend = [self.friendList objectAtIndex:indexPath.row];
    SAFriendCell *cell = [tableView dequeueReusableCellWithIdentifier:cellName forIndexPath:indexPath];
    if (cell) {
        SAFriendCellType cellType;
        switch (self.type) {
            case SAFriendListTypeFollow:
                cellType = SAFriendCellTypeFollow;
                break;
            case SAFriendListTypeFriend:
                cellType = SAFriendCellTypeFriend;
                break;
            case SAFriendListTypeRequest:
                cellType = SAFriendCellTypeRequest;
                break;
        }
        [cell configWithFriend:friend type:cellType];
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    SAFriend *friend = [self.friendList objectAtIndex:indexPath.row];
    self.selectedUserID = friend.friendID;
    if (self.type != SAFriendListTypeRequest) {
        [self performSegueWithIdentifier:@"FriendListToUserSegue" sender:nil];
    } else {
        UIActionSheet *actionSheet;
        if ([friend.following isEqualToNumber:@(YES)]) {
            actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:@"忽略请求" otherButtonTitles:@"接受请求", nil];
            actionSheet.tag = 1;
        } else {
            actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:@"忽略请求" otherButtonTitles:@"接受请求", @"接受请求并关注", nil];
            actionSheet.tag = 2;
        }
        [actionSheet showInView:self.view];
    }
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    SAFriendCell *friendCell = (SAFriendCell *)cell;
    [friendCell loadImage];
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    if (fabs(scrollView.contentSize.height - scrollView.frame.size.height - scrollView.contentOffset.y) < scrollView.contentSize.height * 0.3) {
        [self updateDataWithRefresh:NO];
    }
}

#pragma mark - UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (actionSheet.tag == 1 || actionSheet.tag == 2) {
        if (buttonIndex == 0) {
            [[SAAPIService sharedSingleton] userFriendshipDenyWithUserID:self.selectedUserID success:^(id data) {
                [SAMessageDisplayUtils showInfoWithMessage:@"已忽略"];
            } failure:^(NSString *error) {
                [SAMessageDisplayUtils showInfoWithMessage:error];
            }];
        } else if (buttonIndex == 1) {
            [[SAAPIService sharedSingleton] userFriendshipAcceptWithUserID:self.selectedUserID success:^(id data) {
                [SAMessageDisplayUtils showInfoWithMessage:@"已接受"];
            } failure:^(NSString *error) {
                [SAMessageDisplayUtils showInfoWithMessage:error];
            }];
        } else if (actionSheet.tag == 2 && buttonIndex == 2) {
            [[SAAPIService sharedSingleton] userFriendshipAcceptWithUserID:self.selectedUserID success:^(id data) {
                [[SAAPIService sharedSingleton] followUserWithID:self.selectedUserID success:^(id data) {
                    [SAMessageDisplayUtils showInfoWithMessage:@"已接受并关注"];
                } failure:^(NSString *error) {
                    [SAMessageDisplayUtils showInfoWithMessage:error];
                }];
            } failure:^(NSString *error) {
                [SAMessageDisplayUtils showInfoWithMessage:error];
            }];
        }
    }
}

@end
