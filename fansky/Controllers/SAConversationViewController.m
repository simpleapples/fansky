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

@interface SAConversationViewController ()

@property (strong, nonatomic) NSArray *conversationList;
@property (copy, nonatomic) NSString *selectedUserID;

@end

@implementation SAConversationViewController

static NSString *const ENTITY_NAME = @"SAConversation";
static NSUInteger CONVERSATION_LIST_COUNT = 60;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self updateInterface];
    
    [self getLocalData];
    
    [self refreshData];
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
        [self.refreshControl beginRefreshing];
        if (self.conversationList.count) {
            [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:YES];
        }
    }
    [[SAAPIService sharedSingleton] conversationListWithCount:CONVERSATION_LIST_COUNT success:^(id data) {
        [[SADataManager sharedManager] insertConversationWithObjects:data];
        SAUser *currentUser = [SADataManager sharedManager].currentUser;
        self.conversationList = [[SADataManager sharedManager] currentConversationListWithUserID:currentUser.userID limit:CONVERSATION_LIST_COUNT];
        [self.tableView reloadData];
        [self.refreshControl endRefreshing];
    } failure:^(NSString *error) {
        [SAMessageDisplayUtils showErrorWithMessage:error];
        [self.refreshControl endRefreshing];
    }];
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
    if ([segue.destinationViewController isKindOfClass:[SAMessageViewController class]]) {
        SAMessageViewController *messageViewController = (SAMessageViewController *)segue.destinationViewController;
        messageViewController.userID = self.selectedUserID;
    }
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.conversationList.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *const cellName = @"SAConversationCell";
    SAConversation *conversation = [self.conversationList objectAtIndex:indexPath.row];
    SAConversationCell *cell = [tableView dequeueReusableCellWithIdentifier:cellName forIndexPath:indexPath];
    [cell configWithMessage:conversation];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    SAConversation *conversation = [self.conversationList objectAtIndex:indexPath.row];
    self.selectedUserID = conversation.otherUserID;
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
