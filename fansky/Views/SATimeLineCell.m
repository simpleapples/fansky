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
    
    NSDictionary *linkAttributesDict = @{NSForegroundColorAttributeName: [UIColor colorWithRed:85 / 255.0 green:172 / 255.0 blue:238 / 255.0 alpha:1]};
    self.contentLabel.linkAttributes = linkAttributesDict;
    self.contentLabel.activeLinkAttributes = linkAttributesDict;
    self.contentLabel.text = [[NSAttributedString alloc] initWithData:[self.status.text dataUsingEncoding:NSUnicodeStringEncoding] options:@{NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType} documentAttributes:nil error:nil];
    
    UIFont *newFont = [UIFont systemFontOfSize:14];
    NSMutableAttributedString* attributedString = [self.contentLabel.attributedText mutableCopy];
    [attributedString beginEditing];
    [attributedString enumerateAttribute:NSFontAttributeName inRange:NSMakeRange(0, attributedString.length) options:0 usingBlock:^(id value, NSRange range, BOOL *stop) {
        NSMutableParagraphStyle * paragraphStyle = [[NSMutableParagraphStyle alloc] init];
        [paragraphStyle setLineSpacing:4];
        [attributedString addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:range];
        [attributedString removeAttribute:NSFontAttributeName range:range];
        [attributedString addAttribute:NSFontAttributeName value:newFont range:range];
    }];
    [attributedString endEditing];
    self.contentLabel.text = [attributedString copy];
    self.contentLabel.enabledTextCheckingTypes = NSTextCheckingTypeLink;
    self.contentLabel.delegate = self;
    
    self.timeLabel.text = [self.status.createdAt friendlyDateString];
    self.contentImageView.layer.borderColor = [UIColor colorWithWhite:0.9 alpha:1].CGColor;
    
    if (self.status.photo.thumbURL) {
        self.contentImageView.hidden = NO;
        self.contentImageViewHeightConstraint.constant = (self.frame.size.width - 73) * 0.5;
    } else {
        self.contentImageView.hidden = YES;
        self.contentImageViewHeightConstraint.constant = 1;
    }
}

- (void)loadAllImages
{
    [self.avatarImageView sd_setImageWithURL:[NSURL URLWithString:self.status.user.profileImageURL]];
    if (self.status.photo.thumbURL) {
        [self.contentImageView sd_setImageWithURL:[NSURL URLWithString:self.status.photo.thumbURL]];
    }
}

- (void)attributedLabel:(TTTAttributedLabel *)label didSelectLinkWithURL:(NSURL *)url
{
    
}

#pragma mark - EventHandler

- (IBAction)avatarImageViewTouchUp:(id)sender
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(timeLineCell:avatarImageViewTouchUp:)]) {
        [self.delegate timeLineCell:self avatarImageViewTouchUp:sender];
    }
}

- (IBAction)contentImageViewTouchUp:(id)sender
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(timeLineCell:contentImageViewTouchUp:)]) {
        [self.delegate timeLineCell:self contentImageViewTouchUp:sender];
    }
}

@end
