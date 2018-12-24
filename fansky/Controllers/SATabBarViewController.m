//
//  SATabBarViewController.m
//  fansky
//
//  Created by Zzy on 9/14/15.
//  Copyright (c) 2015 Zzy. All rights reserved.
//

#import "SATabBarViewController.h"
#import "SAUserListViewController.h"
#import "SANotificationManager.h"
#import "SADataManager+User.h"
#import "SAUser+CoreDataProperties.h"
#import "SASearchViewController.h"
#import "SAConversationViewController.h"
#import "UIColor+Utils.h"
#import <SDWebImage/SDWebImageManager.h>
#import "UIImage+Utils.h"

@interface SATabBarViewController ()

@property (weak, nonatomic) IBOutlet UIButton *accountButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *searchButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *composeButton;

@end

@implementation SATabBarViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [[SANotificationManager sharedManager] addObserver:self forKeyPath:@"timeLineCount" options:(NSKeyValueObservingOptionInitial|NSKeyValueObservingOptionNew) context:nil];
    [[SANotificationManager sharedManager] addObserver:self forKeyPath:@"mentionCount" options:(NSKeyValueObservingOptionInitial|NSKeyValueObservingOptionNew) context:nil];
    [[SANotificationManager sharedManager] addObserver:self forKeyPath:@"messageCount" options:(NSKeyValueObservingOptionInitial|NSKeyValueObservingOptionNew) context:nil];
    
    [self updateInterface];
}

- (void)updateInterface
{
    SAUser *currentUser = [SADataManager sharedManager].currentUser;
    if (currentUser && currentUser.profileImageURL.length) {
        NSURL *imageURL = [NSURL URLWithString:currentUser.profileImageURL];
        SDWebImageManager *manager = [SDWebImageManager sharedManager];
        [manager downloadImageWithURL:imageURL options:SDWebImageRefreshCached progress:nil completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
            [self.accountButton setImage: [image circleImage:32] forState:UIControlStateNormal];
        }];
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.destinationViewController isKindOfClass:[SASearchViewController class]]) {
        SASearchViewController *searchViewController = (SASearchViewController *)segue.destinationViewController;
        searchViewController.type = SASearchViewControllerTypeTrend;
    }
}

- (void)dealloc
{
    [[SANotificationManager sharedManager] removeObserver:self forKeyPath:@"timeLineCount"];
    [[SANotificationManager sharedManager] removeObserver:self forKeyPath:@"mentionCount"];
    [[SANotificationManager sharedManager] removeObserver:self forKeyPath:@"messageCount"];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (IBAction)exitToTabBar:(UIStoryboardSegue *)segue
{
    
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"timeLineCount"]) {
        if ([SANotificationManager sharedManager].timeLineCount) {
            NSString *badgeString = @"...";
            if ([SANotificationManager sharedManager].timeLineCount < 60) {
                badgeString = [NSString stringWithFormat:@"%zd", [SANotificationManager sharedManager].timeLineCount];
            }
            UITabBarItem *mentionItem = [self.tabBar.items objectAtIndex:0];
            dispatch_async(dispatch_get_main_queue(), ^{
                mentionItem.badgeValue = badgeString;
            });
        }
    } else if ([keyPath isEqualToString:@"mentionCount"]) {
        if ([SANotificationManager sharedManager].mentionCount) {
            NSString *badgeString = [NSString stringWithFormat:@"%zd", [SANotificationManager sharedManager].mentionCount];
            UITabBarItem *mentionItem = [self.tabBar.items objectAtIndex:1];
            dispatch_async(dispatch_get_main_queue(), ^{
                mentionItem.badgeValue = badgeString;
            });
        }
    } else if ([keyPath isEqualToString:@"messageCount"]) {
        if ([SANotificationManager sharedManager].messageCount) {
            NSString *badgeString = [NSString stringWithFormat:@"%zd", [SANotificationManager sharedManager].messageCount];
            UITabBarItem *messageItem = [self.tabBar.items objectAtIndex:2];
            dispatch_async(dispatch_get_main_queue(), ^{
                messageItem.badgeValue = badgeString;
            });
        }
    }
}

#pragma mark - UITabBarControllerDelegate

- (void)tabBar:(UITabBar *)tabBar didSelectItem:(UITabBarItem *)item
{
    self.navigationItem.title = item.title;
    item.badgeValue = nil;
    if (item.tag == 1) {
        self.searchButton.enabled = YES;
        self.searchButton.tintColor = [UIColor fanskyBlue];
        self.composeButton.enabled = YES;
        self.composeButton.tintColor = [UIColor fanskyBlue];
    } else if (item.tag == 2) {
        self.searchButton.enabled = NO;
        self.searchButton.tintColor = [UIColor clearColor];
        self.composeButton.enabled = NO;
        self.composeButton.tintColor = [UIColor clearColor];
    } else if (item.tag == 3) {
        self.searchButton.enabled = NO;
        self.searchButton.tintColor = [UIColor clearColor];
        self.composeButton.enabled = YES;
        self.composeButton.tintColor = [UIColor fanskyBlue];
    } else if (item.tag == 4) {
        self.searchButton.enabled = NO;
        self.searchButton.tintColor = [UIColor clearColor];
        self.composeButton.enabled = NO;
        self.composeButton.tintColor = [UIColor clearColor];
    }
}

#pragma mark - EventHandler

- (IBAction)accountButtonTouchUp:(id)sender
{
    NSUInteger length = self.navigationController.viewControllers.count;
    id viewController = [self.navigationController.viewControllers objectAtIndex:length - 2];
    if (![viewController isKindOfClass:[SAUserListViewController class]]) {
        NSMutableArray *viewControllers = [self.navigationController.viewControllers mutableCopy];
        SAUserListViewController *userListViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"SAUserListViewController"];
        [viewControllers insertObject:userListViewController atIndex:length - 1];
        self.navigationController.viewControllers = viewControllers;
    }
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)composeButtonTouchUp:(id)sender
{
    if ([self.selectedViewController isKindOfClass:[SAConversationViewController class]]) {
        SAConversationViewController *conversationViewController = (SAConversationViewController *)self.selectedViewController;
        [conversationViewController showFriendPopup];
    } else {
        [self performSegueWithIdentifier:@"TabBarToComposeNavigationSegue" sender:sender];
    }
}

@end
