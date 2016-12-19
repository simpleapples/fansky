//
//  SAConversationViewController.m
//  fansky
//
//  Created by Zzy on 9/20/15.
//  Copyright © 2015 Zzy. All rights reserved.
//

#import "SAConversationViewController.h"
#import "SAMessageDisplayUtils.h"
#import "SADataManager+User.h"
#import "SAUser+CoreDataProperties.h"
#import "SAAPIService.h"
#import "SADataManager+Conversation.h"
#import "SAConversationCell.h"
#import "SAUser+CoreDataProperties.h"
#import "SAMessageViewController.h"
#import "SAConversation+CoreDataProperties.h"
#import "SAMessage+CoreDataProperties.h"
#import "SAUserViewController.h"
#import "SAFriendListViewController.h"
#import "SAFriend.h"
#import "UIColor+Utils.h"
#import "LGRefreshView.h"
#import <STPopup/STPopup.h>

@interface SAConversationViewController () <LGRefreshViewDelegate, SAConversationCellDelegate, SAFriendListViewControllerDelegate>

@property (strong, nonatomic) LGRefreshView *refreshView;

@property (strong, nonatomic) NSArray *conversationList;
@property (copy, nonatomic) NSString *selectedUserID;
@property (strong, nonatomic) STPopupController *popupViewController;

@end

@implementation SAConversationViewController

static NSString *const ENTITY_NAME = @"SAConversation";
static NSString *const CELL_NAME = @"SAConversationCell";
static NSUInteger CONVERSATION_LIST_COUNT = 60;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self updateInterface];
    
    [self getLocalData];
    
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

- (void)getLocalData
{
    SAUser *currentUser = [SADataManager sharedManager].currentUser;
    self.conversationList = [[SADataManager sharedManager] currentConversationListWithUserID:currentUser.userID limit:CONVERSATION_LIST_COUNT];
    [self.tableView reloadData];
}

- (void)refreshData
{
    [self updateDataWithRefresh:YES];
}

- (void)updateDataWithRefresh:(BOOL)refresh
{
    if (refresh) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.refreshView triggerAnimated:YES];
        });
        if (self.conversationList.count) {
            [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:YES];
        }
    }
    [[SAAPIService sharedSingleton] conversationListWithCount:CONVERSATION_LIST_COUNT success:^(id data) {
        [[SADataManager sharedManager] insertOrUpdateConversationsWithObjects:data];
        SAUser *currentUser = [SADataManager sharedManager].currentUser;
        self.conversationList = [[SADataManager sharedManager] currentConversationListWithUserID:currentUser.userID limit:CONVERSATION_LIST_COUNT];
        [self.tableView reloadData];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.refreshView endRefreshing];
        });
    } failure:^(NSString *error) {
        [SAMessageDisplayUtils showErrorWithMessage:error];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.refreshView endRefreshing];
        });
    }];
}

- (void)updateInterface
{
    if (!self.refreshView) {
        self.refreshView = [[LGRefreshView alloc] initWithScrollView:self.tableView delegate:self];
        self.refreshView.tintColor = [UIColor fanskyBlue];
    }    self.clearsSelectionOnViewWillAppear = YES;
    self.tableView.tableFooterView = [UIView new];
    self.tableView.rowHeight = 70;
}

- (void)showFriendPopup
{
    SAUser *currentUser = [SADataManager sharedManager].currentUser;
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"SAMine" bundle:[NSBundle mainBundle]];
    SAFriendListViewController *friendListViewController = (SAFriendListViewController *)[storyboard instantiateViewControllerWithIdentifier:@"SAFriendListViewController"];
    friendListViewController.delegate = self;
    friendListViewController.userID = currentUser.userID;
    friendListViewController.type = SAFriendListTypeFriendPopup;
    self.popupViewController = [[STPopupController alloc] initWithRootViewController:friendListViewController];
    [self.popupViewController presentInViewController:self];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.destinationViewController isKindOfClass:[SAMessageViewController class]]) {
        SAMessageViewController *messageViewController = (SAMessageViewController *)segue.destinationViewController;
        messageViewController.userID = self.selectedUserID;
    } else if ([segue.destinationViewController isKindOfClass:[SAUserViewController class]]) {
        SAUserViewController *userViewController = (SAUserViewController *)segue.destinationViewController;
        userViewController.userID = self.selectedUserID;
    }
}

#pragma mark - SAFriendListViewControllerDelegate

- (void)friendListViewController:(SAFriendListViewController *)friendListViewController selectedfriend:(SAFriend *)selectedFriend
{
    [self.popupViewController dismiss];
    self.selectedUserID = selectedFriend.friendID;
    [SAMessageDisplayUtils showProgressWithMessage:@"载入中"];
    [[SAAPIService sharedSingleton] userWithID:self.selectedUserID success:^(id data) {
        [[SADataManager sharedManager] insertOrUpdateUserWithObject:data local:NO active:NO token:nil secret:nil];
        [SAMessageDisplayUtils dismiss];
        [self performSegueWithIdentifier:@"ConversationToMessageSegue" sender:nil];
    } failure:^(NSString *error) {
        [SAMessageDisplayUtils dismiss];
    }];
}

#pragma mark - SAConversationCellDelegate

- (void)conversationCell:(SAConversationCell *)conversationCell avatarImageViewTouchUp:(id)sender
{
    self.selectedUserID = conversationCell.otherUser.userID;
    [self performSegueWithIdentifier:@"ConversationToUserSegue" sender:nil];
}

#pragma mark - LGRefreshViewDelegate

- (void)refreshViewRefreshing:(LGRefreshView *)refreshView
{
    [self refreshData];
}

#pragma mark - UITableViewDelegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.conversationList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    SAConversation *conversation = [self.conversationList objectAtIndex:indexPath.row];
    SAConversationCell *cell = [tableView dequeueReusableCellWithIdentifier:CELL_NAME forIndexPath:indexPath];
    cell.delegate = self;
    [cell configWithMessage:conversation];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    SAConversation *conversation = [self.conversationList objectAtIndex:indexPath.row];
    NSString *otherUserID;
    if ([conversation.otherUserID isEqualToString:conversation.message.senderID]) {
        otherUserID = conversation.message.sender.userID;
    } else {
        otherUserID = conversation.message.recipient.userID;
    }
    self.selectedUserID = otherUserID;
    [self performSegueWithIdentifier:@"ConversationToMessageSegue" sender:nil];
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([cell isKindOfClass:[SAConversationCell class]]) {
        SAConversationCell *conversationCell = (SAConversationCell *)cell;
        [conversationCell loadImage];
    }
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    if (fabs(scrollView.contentSize.height - scrollView.frame.size.height - scrollView.contentOffset.y) < scrollView.contentSize.height * 0.3) {
        [self updateDataWithRefresh:NO];
    }
}


@end
