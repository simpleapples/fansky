//
//  SATimeLinePhotoCell.m
//  fansky
//
//  Created by Zzy on 9/18/15.
//  Copyright © 2015 Zzy. All rights reserved.
//

#import "SATimeLinePhotoCell.h"
#import "SAStatus+CoreDataProperties.h"
#import "SAPhoto.h"
#import "SAUser+CoreDataProperties.h"
#import "NSDate+Utils.h"
#import "TTTAttributedLabel.h"
#import <SDWebImage/UIImageView+WebCache.h>

@interface SATimeLinePhotoCell () <TTTAttributedLabelDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *avatarImageView;
@property (weak, nonatomic) IBOutlet UILabel *usernameLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet TTTAttributedLabel *contentLabel;
@property (weak, nonatomic) IBOutlet UIImageView *contentImageView;

@end

@implementation SATimeLinePhotoCell

- (void)prepareForReuse
{
    [super prepareForReuse];
    
    self.usernameLabel.text = nil;
    self.timeLabel.text = nil;
    self.contentLabel.text = nil;
    self.contentLabel.delegate = nil;
    [self.avatarImageView setImage:nil];
    [self.contentImageView setImage:nil];
}

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
    
    UIFont *newFont = [UIFont fontWithName:@"HelveticaNeue-Light" size:16];
    NSMutableAttributedString* attributedString = [self.contentLabel.attributedText mutableCopy];
    [attributedString beginEditing];
    [attributedString enumerateAttribute:NSFontAttributeName inRange:NSMakeRange(0, attributedString.length) options:0 usingBlock:^(id value, NSRange range, BOOL *stop) {
        NSMutableParagraphStyle * paragraphStyle = [[NSMutableParagraphStyle alloc] init];
        [paragraphStyle setLineSpacing:6];
        [attributedString addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:range];
        [attributedString removeAttribute:NSFontAttributeName range:range];
        [attributedString addAttribute:NSFontAttributeName value:newFont range:range];
        [attributedString addAttribute:NSUnderlineStyleAttributeName value:@(NSUnderlineStyleNone) range:range];
    }];
    [attributedString endEditing];
    self.contentLabel.text = [attributedString copy];
    self.contentLabel.enabledTextCheckingTypes = NSTextCheckingTypeLink;
    self.contentLabel.delegate = self;
    
    self.timeLabel.text = [self.status.createdAt friendlyDateString];
    self.contentImageView.layer.borderColor = [UIColor colorWithWhite:0.9 alpha:1].CGColor;
}

- (void)loadAllImages
{
    [self.avatarImageView sd_setImageWithURL:[NSURL URLWithString:self.status.user.profileImageURL] placeholderImage:nil options:SDWebImageRefreshCached];
    if (self.status.photo.thumbURL) {
        [self.contentImageView sd_setImageWithURL:[NSURL URLWithString:self.status.photo.largeURL] placeholderImage:nil options:SDWebImageRefreshCached];
    }
}

- (void)attributedLabel:(TTTAttributedLabel *)label didSelectLinkWithURL:(NSURL *)url
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(timeLinePhotoCell:contentURLTouchUp:)]) {
        self.selectedURL = url;
        [self.delegate timeLinePhotoCell:self contentURLTouchUp:nil];
    }
}

#pragma mark - EventHandler

- (IBAction)avatarImageViewTouchUp:(id)sender
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(timeLinePhotoCell:avatarImageViewTouchUp:)]) {
        [self.delegate timeLinePhotoCell:self avatarImageViewTouchUp:sender];
    }
}

- (IBAction)contentImageViewTouchUp:(id)sender
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(timeLinePhotoCell:contentImageViewTouchUp:)]) {
        [self.delegate timeLinePhotoCell:self contentImageViewTouchUp:sender];
    }
}

@end
