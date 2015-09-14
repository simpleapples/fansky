//
//  SATimeLineCell.m
//  fansky
//
//  Created by Zzy on 6/23/15.
//  Copyright (c) 2015 Zzy. All rights reserved.
//

#import "SATimeLineCell.h"
#import "SAStatus.h"
#import "SAPhoto.h"
#import "SAUser.h"
#import <SDWebImage/UIImageView+WebCache.h>

@interface SATimeLineCell ()

@property (weak, nonatomic) IBOutlet UIImageView *avatarImageView;
@property (weak, nonatomic) IBOutlet UILabel *usernameLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UILabel *contentLabel;
@property (weak, nonatomic) IBOutlet UIImageView *contentImageView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *contentImageViewHeightConstraint;

@end

@implementation SATimeLineCell

- (void)configWithStatus:(SAStatus *)status
{
    self.usernameLabel.text = status.user.name;
    self.contentLabel.text = status.text;
    [self.avatarImageView sd_setImageWithURL:[NSURL URLWithString:status.user.profileImageURL]];
    
    if (status.photo.thumbURL) {
        self.contentImageView.hidden = NO;
        self.contentImageViewHeightConstraint.constant = (self.frame.size.width - 73) * 0.5;
        [self.contentImageView sd_setImageWithURL:[NSURL URLWithString:status.photo.thumbURL]];
    } else {
        self.contentImageView.hidden = YES;
        self.contentImageViewHeightConstraint.constant = 1;
    }
}

@end
