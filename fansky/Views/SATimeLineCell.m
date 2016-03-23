//
//  SATimeLineCell.m
//  fansky
//
//  Created by Zzy on 9/18/15.
//  Copyright © 2015 Zzy. All rights reserved.
//

#import "SATimeLineCell.h"
#import "SAStatus.h"
#import "SAPhoto.h"
#import "SAUser.h"
#import "NSDate+Utils.h"
#import "UIColor+Utils.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import <DTCoreText/DTCoreText.h>

@interface SATimeLineCell () <DTAttributedTextContentViewDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *avatarImageView;
@property (weak, nonatomic) IBOutlet UIImageView *iconGIFImageView;
@property (weak, nonatomic) IBOutlet UILabel *usernameLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet DTAttributedLabel *contentLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *contentHeightConstraint;

@end

@implementation SATimeLineCell

- (void)prepareForReuse
{
    [super prepareForReuse];
    
    self.usernameLabel.text = nil;
    self.timeLabel.text = nil;
    self.contentLabel.attributedString = nil;
    self.contentLabel.delegate = nil;
    [self.avatarImageView setImage:nil];
    [self.contentImageView setImage:nil];
    self.iconGIFImageView.hidden = YES;
}

- (void)configWithStatus:(SAStatus *)status
{
    self.status = status;
    
    [self updateInterface];
}

- (void)updateInterface
{
    self.avatarImageView.layer.rasterizationScale = [UIScreen mainScreen].scale;
    self.contentImageView.layer.rasterizationScale = [UIScreen mainScreen].scale;
    
    UIColor *linkColor = [UIColor fanskyBlue];
    NSDictionary *optionDictionary = @{DTDefaultFontName: @"HelveticaNeue-Light",
                                       DTDefaultFontSize: @(16),
                                       DTDefaultLinkColor: linkColor,
                                       DTDefaultLinkHighlightColor: linkColor,
                                       DTDefaultLinkDecoration: @(NO),
                                       DTDefaultLineHeightMultiplier: @(1.5)};
    NSAttributedString* attributedString = [[NSAttributedString alloc] initWithHTMLData:[self.status.text dataUsingEncoding:NSUnicodeStringEncoding] options:optionDictionary documentAttributes:nil];
    
    self.timeLabel.text = [self.status.createdAt friendlyDateString];
    self.usernameLabel.text = self.status.user.name;
    self.contentImageView.layer.borderColor = [UIColor colorWithWhite:0.9 alpha:1].CGColor;
    self.contentLabel.attributedString = attributedString;
    self.contentLabel.lineBreakMode = NSLineBreakByCharWrapping;
    self.contentLabel.numberOfLines = 0;
    self.contentLabel.delegate = self;
}

- (void)loadAllImages
{
    [self.avatarImageView sd_setImageWithURL:[NSURL URLWithString:self.status.user.profileImageURL] placeholderImage:[UIImage imageNamed:@"BackgroundAvatar"] options:SDWebImageRefreshCached];
    if (self.status.photo.largeURL) {
        self.contentHeightConstraint.constant = self.frame.size.height - 72 - (self.frame.size.width - 86) / 2;
        [self.contentImageView sd_setImageWithURL:[NSURL URLWithString:self.status.photo.largeURL] placeholderImage:[UIImage imageNamed:@"BackgroundImage"] options:SDWebImageRefreshCached completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
            if ([self.status.photo.largeURL hasSuffix:@".gif"]) {
                self.iconGIFImageView.hidden = NO;
                self.contentImageView.image = image.images.firstObject;
            }
        }];
        self.contentImageView.hidden = NO;
    } else {
        self.contentHeightConstraint.constant = self.frame.size.height - 62;
        self.contentImageView.hidden = YES;
    }
    [self setNeedsLayout];
}

- (CGRect)sourceRectWithLocation:(CGPoint)location
{
    if (self.status.photo.largeURL) {
        CGPoint imageOrigin = self.contentImageView.frame.origin;
        CGSize imageSize = self.contentImageView.frame.size;
        if (location.x >= imageOrigin.x && location.x <= imageOrigin.x + imageSize.width && location.y >= imageOrigin.y && location.y <= imageOrigin.y + imageSize.height) {
            return self.contentImageView.frame;
        }
    }
    return CGRectZero;
}

- (CGRect)contentImageViewRect
{
    return self.contentImageView.frame;
}

#pragma mark - DTAttributedTextContentViewDelegate

- (UIView *)attributedTextContentView:(DTAttributedTextContentView *)attributedTextContentView viewForLink:(NSURL *)url identifier:(NSString *)identifier frame:(CGRect)frame
{
    DTLinkButton *linkButton = [[DTLinkButton alloc] initWithFrame:frame];
    linkButton.URL = url;
    [linkButton addTarget:self action:@selector(linkButtonTouchUp:) forControlEvents:UIControlEventTouchUpInside];
    return linkButton;
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
    if (!self.status.photo.largeURL.length) {
        return;
    }
    if (self.delegate && [self.delegate respondsToSelector:@selector(timeLineCell:contentImageViewTouchUp:)]) {
        [self.delegate timeLineCell:self contentImageViewTouchUp:sender];
    }
}

- (void)linkButtonTouchUp:(DTLinkButton *)sender
{
    NSURL *URL = sender.URL;
    if (self.delegate && [self.delegate respondsToSelector:@selector(timeLineCell:contentURLTouchUp:)]) {
        self.selectedURL = URL;
        [self.delegate timeLineCell:self contentURLTouchUp:nil];
    }
}

- (UIEdgeInsets)layoutMargins
{
    return UIEdgeInsetsZero;
}

@end
