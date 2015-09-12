//
//  SATimeLineCell.m
//  fansky
//
//  Created by Zzy on 6/23/15.
//  Copyright (c) 2015 Zzy. All rights reserved.
//

#import "SATimeLineCell.h"
#import "SAStatus.h"

@interface SATimeLineCell ()

@property (weak, nonatomic) IBOutlet UIImageView *avatarImageView;
@property (weak, nonatomic) IBOutlet UILabel *usernameLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UITextView *contentTextView;
@property (weak, nonatomic) IBOutlet UIImageView *contentImageView;

@end

@implementation SATimeLineCell

- (void)configWithStatus:(SAStatus *)status
{
    
}

@end
