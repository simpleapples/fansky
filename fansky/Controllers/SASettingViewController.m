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
#import <LTHPasscodeViewController/LTHPasscodeViewController.h>
#import <VTAcknowledgementsViewController/VTAcknowledgementsViewController.h>

@interface SASettingViewController () <LTHPasscodeViewControllerDelegate>

@property (weak, nonatomic) IBOutlet UISwitch *passcodeSwitch;
@property (weak, nonatomic) IBOutlet UILabel *versionLabel;

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
    [self updatePasscodeSwitch];

    NSDictionary *info = [[NSBundle mainBundle] infoDictionary];
    NSString *versionString = [NSString stringWithFormat:@"%@ (%@)", [info objectForKey:@"CFBundleShortVersionString"], [info objectForKey:@"CFBundleVersion"]];
    self.versionLabel.text = versionString;
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
            NSString *path = [[NSBundle mainBundle] pathForResource:@"Pods-fansky-acknowledgements" ofType:@"plist"];
            VTAcknowledgementsViewController *acknowledgementViewController = [[VTAcknowledgementsViewController alloc] initWithAcknowledgementsPlistPath:path];
            acknowledgementViewController.title = @"致谢";
            acknowledgementViewController.headerText = @"饭斯基使用了如下开源组件";
            acknowledgementViewController.footerText = @"使用 CocoaPods 生成";
            [self.navigationController showViewController:acknowledgementViewController sender:nil];
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
