//
//  SAUserListViewController.m
//  fansky
//
//  Created by Zzy on 9/10/15.
//  Copyright (c) 2015 Zzy. All rights reserved.
//

#import "SAUserListViewController.h"
#import "SADataManager+User.h"
#import "SAUserCell.h"
#import "SAUser.h"

@interface SAUserListViewController ()

@property (strong, nonatomic) RLMResults *userList;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *editButton;

@end

@implementation SAUserListViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self updateInterface];
    [self getLocalData];
}

- (void)viewDidAppear:(BOOL)animated
{
    [self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:animated];
    [super viewDidAppear:animated];
    SAUser *currentUser = [SADataManager sharedManager].currentUser;
    [self.tableView reloadData];
    if (!currentUser) {
        [self performSegueWithIdentifier:@"UserListToAuthNavigationSegue" sender:nil];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)updateInterface
{
    self.tableView.tableFooterView = [UIView new];
}

- (void)getLocalData
{
    self.userList = [[SADataManager sharedManager] localUsers];
    [self.tableView reloadData];
}

- (IBAction)exitToUserList:(UIStoryboardSegue *)segue
{
    
}

#pragma mark - UITableViewDelegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.userList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    SAUserCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SAUserCell" forIndexPath:indexPath];
    if (cell) {
        SAUser *user = [self.userList objectAtIndex:indexPath.row];
        [cell configWithUser:user];
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    SAUser *user = [self.userList objectAtIndex:indexPath.row];
    [[SADataManager sharedManager] setCurrentUserWithUserID:user.userID];
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(nonnull NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        SAUser *user = [self.userList objectAtIndex:indexPath.row];
        [[SADataManager sharedManager] deleteUserWithUserID:user.userID];
    }
}

#pragma mark - EventHandler

- (IBAction)addButtonTouchUp:(id)sender
{
    [self performSegueWithIdentifier:@"UserListToAuthNavigationSegue" sender:nil];
}

- (IBAction)editButtonTouchUp:(id)sender
{
    UIBarButtonItem *editButton = (UIBarButtonItem *)sender;
    if ([editButton.title isEqualToString:@"编辑"]) {
        self.tableView.editing = YES;
        editButton.title = @"完成";
    } else if ([editButton.title isEqualToString:@"完成"]) {
        self.tableView.editing = NO;
        editButton.title = @"编辑";
    }
}

@end
