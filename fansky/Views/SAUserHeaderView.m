//
//  SAUserHeaderView.m
//  fansky
//
//  Created by Zzy on 9/15/15.
//  Copyright (c) 2015 Zzy. All rights reserved.
//

#import "SAUserHeaderView.h"
#import "SAUser.h"
#import "SADataManager+User.h"
#import "SAAPIService.h"
#import <SDWebImage/UIImageView+WebCache.h>

@interface SAUserHeaderView ()

@property (weak, nonatomic) IBOutlet UIImageView *avatarImageView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *userIDLabel;
@property (weak, nonatomic) IBOutlet UILabel *descLabel;
@property (weak, nonatomic) IBOutlet UIButton *followButton;

@property (strong, nonatomic) SAUser *user;

@end

@implementation SAUserHeaderView

- (void)configWithUserID:(NSString *)userID
{
    self.user = [[SADataManager sharedManager] userWithID:userID];
    if (!self.user) {
        [[SAAPIService sharedSingleton] userWithID:userID success:^(id data) {
            [[SADataManager sharedManager] insertOrUpdateUserWithObject:data local:NO active:NO token:nil secret:nil];
            [self updateInterface];
        } failure:^(NSError *error) {
            
        }];
    } else {
        [self updateInterface];
    }
}

- (void)updateInterface
{
    self.avatarImageView.layer.borderColor = [UIColor whiteColor].CGColor;
    
    self.nameLabel.text = self.user.name;
    self.userIDLabel.text = [NSString stringWithFormat:@"@%@", self.user.userID];
    self.descLabel.text = @"";
    [self.avatarImageView sd_setImageWithURL:[NSURL URLWithString:self.user.profileImageURL]];
}

- (IBAction)followButtonTouchUp:(id)sender
{
}

@end
