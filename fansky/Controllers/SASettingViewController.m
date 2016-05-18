//
//  SASettingViewController.m
//  fansky
//
//  Created by Zzy on 9/20/15.
//  Copyright © 2015 Zzy. All rights reserved.
//

#import "SASettingViewController.h"
#import "SAUserViewController.h"
#import "SAFriendListViewController.h"
#import "SADataManager+User.h"
#import "SAUser+CoreDataProperties.h"
#import "SANotificationManager.h"
#import <LTHPasscodeViewController/LTHPasscodeViewController.h>
#import <SDWebImage/SDImageCache.h>

@interface SASettingViewController () <LTHPasscodeViewControllerDelegate>

@property (weak, nonatomic) IBOutlet UILabel *friendRequestCountLabel;
@property (weak, nonatomic) IBOutlet UISwitch *passcodeSwitch;
@property (weak, nonatomic) IBOutlet UILabel *cacheSizeLabel;

@end

@implementation SASettingViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [LTHPasscodeViewController sharedUser].delegate = self;
    
    [self updateInterface];
}

- (void)viewWillAppear:(BOOL)animated
{
    [self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:animated];
    [super viewWillAppear:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)updatePasscodeSwitch
{
    self.passcodeSwitch.on = [LTHPasscodeViewController doesPasscodeExist];
}

- (void)updateInterface
{
    self.friendRequestCountLabel.text = [NSString stringWithFormat:@"%ld", [SANotificationManager sharedManager].friendRequestCount];
    
    [self updatePasscodeSwitch];
    
    [self updateCacheSize];
}

- (void)updateCacheSize
{
    [[SDImageCache sharedImageCache] calculateSizeWithCompletionBlock:^(NSUInteger fileCount, NSUInteger totalSize) {
        self.cacheSizeLabel.text = [NSByteCountFormatter stringFromByteCount:totalSize countStyle:NSByteCountFormatterCountStyleFile];
    }];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.destinationViewController isKindOfClass:[SAFriendListViewController class]]) {
        SAUser *currentUser = [SADataManager sharedManager].currentUser;
        SAFriendListViewController *friendListViewController = (SAFriendListViewController *)segue.destinationViewController;
        friendListViewController.type = SAFriendListTypeRequest;
        friendListViewController.userID = currentUser.userID;
    }
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UINavigationController *navigationController = (UINavigationController *)self.navigationController.presentingViewController;
    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            [self performSegueWithIdentifier:@"SettingToFriendListSegue" sender:nil];
        }
    } else if (indexPath.section == 1) {
        if (indexPath.row == 1) {
            [tableView deselectRowAtIndexPath:indexPath animated:YES];
            [[SDImageCache sharedImageCache] clearDiskOnCompletion:^{
                [self updateCacheSize];
            }];
        }
    } else if (indexPath.section == 2) {
        if (indexPath.row == 0) {
            [self dismissViewControllerAnimated:YES completion:^{
                SAUserViewController *userViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"SAUserViewController"];
                userViewController.userID = @"fansky";
                dispatch_async(dispatch_get_main_queue(), ^{
                    [navigationController showViewController:userViewController sender:nil];
                });
            }];
        } else if (indexPath.row == 1) {
            NSString *appID = @"1039622797";
            NSString *url = [NSString stringWithFormat:@"itms-apps://itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?type=Purple+Software&id=%@", appID];
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
        }
    }
}

#pragma mark - LTHPasscodeViewControllerDelegate

- (void)passcodeViewControllerWillClose
{
    [self updatePasscodeSwitch];
}

#pragma mark - EventHandler

- (IBAction)closeButtonTouchUp:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)passcodeSwitchValueChanged:(id)sender
{
    if (![LTHPasscodeViewController doesPasscodeExist]) {
        [[LTHPasscodeViewController sharedUser] showForEnablingPasscodeInViewController:self asModal:YES];
    } else {
        [[LTHPasscodeViewController sharedUser] showForDisablingPasscodeInViewController:self asModal:YES];
    }
}

@end
