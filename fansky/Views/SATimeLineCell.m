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
#import "NSDate+Utils.h"
#import "TTTAttributedLabel.h"
#import <SDWebImage/UIImageView+WebCache.h>

@interface SATimeLineCell () <TTTAttributedLabelDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *avatarImageView;
@property (weak, nonatomic) IBOutlet UILabel *usernameLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet TTTAttributedLabel *contentLabel;
@property (weak, nonatomic) IBOutlet UIImageView *contentImageView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *contentImageViewHeightConstraint;

@end

@implementation SATimeLineCell

- (void)configWithStatus:(SAStatus *)status
{
    self.status = status;
    
    [self updateInterface];
}

- (void)updateInterface
{
    self.usernameLabel.text = self.status.user.name;
    NSString *contentString = [NSString stringWithFormat:@"<style>.former{color:#55ACEE}</style>%@", self.status.text];
    self.contentLabel.text = [[NSAttributedString alloc] initWithData:[contentString dataUsingEncoding:NSUnicodeStringEncoding] options:@{NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType} documentAttributes:nil error:nil];
    
    UIFont *newFont = [UIFont systemFontOfSize:14];
    NSMutableAttributedString* attributedString = [self.contentLabel.attributedText mutableCopy];
    [attributedString beginEditing];
    [attributedString enumerateAttribute:NSFontAttributeName inRange:NSMakeRange(0, attributedString.length) options:0 usingBlock:^(id value, NSRange range, BOOL *stop) {
        NSMutableParagraphStyle * paragraphStyle = [[NSMutableParagraphStyle alloc] init];
        [paragraphStyle setLineSpacing:4];
        [attributedString addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:range];
        [attributedString addAttribute:NSUnderlineStyleAttributeName value:@(NSUnderlineStyleNone) range:range];
        [attributedString removeAttribute:NSFontAttributeName range:range];
        [attributedString addAttribute:NSFontAttributeName value:newFont range:range];
    }];
    [attributedString endEditing];
    self.contentLabel.text = [attributedString copy];
    self.contentLabel.enabledTextCheckingTypes = NSTextCheckingTypeLink;
    self.contentLabel.delegate = self;
    self.timeLabel.text = [self.status.createdAt friendlyDateString];
    [self.avatarImageView sd_setImageWithURL:[NSURL URLWithString:self.status.user.profileImageURL]];
    self.contentImageView.layer.borderColor = [UIColor colorWithWhite:0.9 alpha:1].CGColor;
    
    if (self.status.photo.thumbURL) {
        self.contentImageView.hidden = NO;
        self.contentImageViewHeightConstraint.constant = (self.frame.size.width - 73) * 0.5;
        [self.contentImageView sd_setImageWithURL:[NSURL URLWithString:self.status.photo.largeURL]];
    } else {
        self.contentImageView.hidden = YES;
        self.contentImageViewHeightConstraint.constant = 1;
    }
}

- (void)attributedLabel:(TTTAttributedLabel *)label didSelectLinkWithURL:(NSURL *)url
{
    
}

- (IBAction)avatarImageViewTouchUp:(id)sender
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(timeLineCell:avatarImageViewTouchUp:)]) {
        [self.delegate timeLineCell:self avatarImageViewTouchUp:sender];
    }
}

@end
