//
//  SAUserCell.m
//  fansky
//
//  Created by Zzy on 9/11/15.
//  Copyright (c) 2015 Zzy. All rights reserved.
//

#import "SAUserCell.h"
#import "SAUser+CoreDataProperties.h"
#import <SDWebImage/UIImageView+WebCache.h>

@interface SAUserCell ()

@property (weak, nonatomic) IBOutlet UIImageView *avatarImageView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *IDLabel;

@end

@implementation SAUserCell

- (void)configWithUser:(SAUser *)user
{
    [self.avatarImageView sd_setImageWithURL:[NSURL URLWithString:user.profileImageURL]];
    self.nameLabel.text = user.name;
    self.IDLabel.text = user.userID;
}

@end
