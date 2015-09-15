//
//  SAStatusViewController.m
//  fansky
//
//  Created by Zzy on 9/15/15.
//  Copyright (c) 2015 Zzy. All rights reserved.
//

#import "SAStatusViewController.h"
#import "SADataManager+Status.h"
#import "SAStatus.h"
#import "SAUser.h"
#import "SAPhoto.h"
#import "SAUserViewController.h"
#import "SADataManager+User.h"
#import "NSDate+Utils.h"
#import <SDWebImage/UIImageView+WebCache.h>

@interface SAStatusViewController ()

@property (weak, nonatomic) IBOutlet UIImageView *avatarImageView;
@property (weak, nonatomic) IBOutlet UILabel *usernameLabel;
@property (weak, nonatomic) IBOutlet UILabel *contentLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *trashBarButton;

@property (weak, nonatomic) IBOutlet UIImageView *contentImageView;
@property (strong, nonatomic) SAStatus *status;

@end

@implementation SAStatusViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.status = [[SADataManager sharedManager] statusWithID:self.statusID];
    
    [self updateInterface];
}

- (void)updateInterface
{
    SAUser *currentUser = [SADataManager sharedManager].currentUser;
    if ([self.status.user.userID isEqualToString:currentUser.userID]) {
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"IconTrash"] style:UIBarButtonItemStyleDone target:self action:@selector(trashBarButtonTouchUp:)];
    } else {
        self.navigationItem.rightBarButtonItem = nil;
    }
    
    self.usernameLabel.text = self.status.user.name;
    self.contentLabel.text = self.status.text;
    self.timeLabel.text = [self.status.createdAt friendlyDateString];
    [self.avatarImageView sd_setImageWithURL:[NSURL URLWithString:self.status.user.profileImageURL]];
    self.contentImageView.layer.borderColor = [UIColor colorWithWhite:0.9 alpha:1].CGColor;
    
    if (self.status.photo.thumbURL) {
        self.contentImageView.hidden = NO;
        [self.contentImageView sd_setImageWithURL:[NSURL URLWithString:self.status.photo.largeURL]];
    } else {
        self.contentImageView.hidden = YES;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.destinationViewController isKindOfClass:[SAUserViewController class]]) {
        SAUserViewController *userViewController = (SAUserViewController *)segue.destinationViewController;
        userViewController.userID = self.status.user.userID;
    }
}

- (IBAction)trashBarButtonTouchUp:(id)sender
{
}

@end
