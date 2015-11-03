//
//  SAStatusViewController.m
//  fansky
//
//  Created by Zzy on 9/15/15.
//  Copyright (c) 2015 Zzy. All rights reserved.
//

#import "SAStatusViewController.h"
#import "SADataManager+Status.h"
#import "SAStatus+CoreDataProperties.h"
#import "SAUser+CoreDataProperties.h"
#import "SAPhoto.h"
#import "SAUserViewController.h"
#import "SADataManager+User.h"
#import "SAComposeViewController.h"
#import "SAAPIService.h"
#import "SAMessageDisplayUtils.h"
#import "NSDate+Utils.h"
#import "NSString+Utils.h"
#import "UIColor+Utils.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import <DTCoreText/DTCoreText.h>
#import <URBMediaFocusViewController/URBMediaFocusViewController.h>
#import <MobileCoreServices/UTCoreTypes.h>

@interface SAStatusViewController () <DTAttributedTextContentViewDelegate, UIActionSheetDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *avatarImageView;
@property (weak, nonatomic) IBOutlet UILabel *usernameLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet DTAttributedLabel *contentLabel;
@property (weak, nonatomic) IBOutlet UIImageView *contentImageView;
@property (weak, nonatomic) IBOutlet UIButton *starButton;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *timeLabelTopToLabelMarginConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *timeLabelTopToImageViewMarginConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *contentLabelHeightConstraint;
@property (strong, nonatomic) URBMediaFocusViewController *imageViewController;
@property (strong, nonatomic) SAStatus *status;
@property (copy, nonatomic) NSString *selectedUserID;

@end

@implementation SAStatusViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.status = [[SADataManager sharedManager] statusWithID:self.statusID];
    
    [self updateInterface];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [SAMessageDisplayUtils dismiss];
    [super viewWillDisappear:animated];
}

- (void)updateStarButton
{
    if ([self.status.favorited isEqualToNumber:@(YES)]) {
        self.starButton.selected = YES;
    } else {
        self.starButton.selected = NO;
    }
}

- (void)updateInterface
{
    [self updateStarButton];
    
    self.usernameLabel.text = self.status.user.name;
    self.timeLabel.text = [NSString stringWithFormat:@"%@ ∙ 通过%@", [self.status.createdAt dateStringWithFormat:@"MM-dd HH:mm"], [self.status.source flattenHTML]];
    [self.avatarImageView sd_setImageWithURL:[NSURL URLWithString:self.status.user.profileImageURL] placeholderImage:nil options:SDWebImageRefreshCached];
    self.contentImageView.layer.borderColor = [UIColor colorWithWhite:0.9 alpha:1].CGColor;
    
    UIColor *linkColor = [UIColor fanskyBlue];
    
    NSDictionary *optionDictionary = @{DTDefaultFontName: @"HelveticaNeue-Light",
                                       DTDefaultFontSize: @(16),
                                       DTDefaultLinkColor: linkColor,
                                       DTDefaultLinkHighlightColor: linkColor,
                                       DTDefaultLinkDecoration: @(NO),
                                       DTDefaultLineHeightMultiplier: @(1.5)};
    NSAttributedString* attributedString = [[NSAttributedString alloc] initWithHTMLData:[self.status.text dataUsingEncoding:NSUnicodeStringEncoding] options:optionDictionary documentAttributes:nil];
    
    self.contentLabel.attributedString = attributedString;
    self.contentLabel.lineBreakMode = NSLineBreakByCharWrapping;
    self.contentLabel.numberOfLines = 0;
    self.contentLabel.delegate = self;
    DTCoreTextLayouter *layouter = [[DTCoreTextLayouter alloc] initWithAttributedString:attributedString];
    
    CGFloat width = self.view.frame.size.width - 86;
    CGRect maxRect = CGRectMake(0, 0, width, CGFLOAT_HEIGHT_UNKNOWN);
    NSRange entireString = NSMakeRange(0, attributedString.length);
    DTCoreTextLayoutFrame *layoutFrame = [layouter layoutFrameWithRect:maxRect range:entireString];
    self.contentLabelHeightConstraint.constant = layoutFrame.frame.size.height;
    
    if (self.status.photo.thumbURL) {
        self.contentImageView.hidden = NO;
        [self.contentImageView sd_setImageWithURL:[NSURL URLWithString:self.status.photo.largeURL] placeholderImage:nil options:SDWebImageRefreshCached];
        self.timeLabelTopToImageViewMarginConstraint.priority = UILayoutPriorityRequired;
    } else {
        self.contentImageView.hidden = YES;
        self.timeLabelTopToLabelMarginConstraint.priority = UILayoutPriorityRequired;
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
        userViewController.userID = self.selectedUserID;
    } else if ([segue.destinationViewController isKindOfClass:[UINavigationController class]]) {
        UINavigationController *navigationController = segue.destinationViewController;
        if ([[navigationController.viewControllers firstObject] isKindOfClass:[SAComposeViewController class]]) {
            SAComposeViewController *composeViewController = (SAComposeViewController *)[navigationController.viewControllers firstObject];
            UIButton *button = (UIButton *)sender;
            if (button.tag == 1) {
                composeViewController.replyToStatusID = self.status.statusID;
            } else if (button.tag == 2) {
                composeViewController.repostStatusID = self.status.statusID;
            }
        }
    }
}

#pragma mark - DTAttributedTextContentViewDelegate

- (UIView *)attributedTextContentView:(DTAttributedTextContentView *)attributedTextContentView viewForLink:(NSURL *)url identifier:(NSString *)identifier frame:(CGRect)frame
{
    DTLinkButton *linkButton = [[DTLinkButton alloc] initWithFrame:frame];
    linkButton.URL = url;
    [linkButton addTarget:self action:@selector(linkButtonTouchUp:) forControlEvents:UIControlEventTouchUpInside];
    return linkButton;
}


#pragma mark - UIActionSheet

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (actionSheet.tag == 1) {
        if (buttonIndex == 0) {
            UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
            NSString *pasteString = [self.status.text flattenHTML];
            pasteboard.string = pasteString;
            [SAMessageDisplayUtils showInfoWithMessage:@"已复制"];
        }
    } else if (actionSheet.tag == 2) {
        if (buttonIndex == 0) {
            [[SAAPIService sharedSingleton] deleteStatusWithID:self.statusID success:^(id data) {
                [[SADataManager sharedManager] deleteStatusWithID:self.statusID];
                [SAMessageDisplayUtils showSuccessWithMessage:@"删除成功"];
                [self.navigationController popViewControllerAnimated:YES];
            } failure:^(NSString *error) {
                [SAMessageDisplayUtils showErrorWithMessage:error];
            }];
        } else if (buttonIndex == 1) {
            UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
            NSString *pasteString = [self.status.text flattenHTML];
            pasteboard.string = pasteString;
            [SAMessageDisplayUtils showInfoWithMessage:@"已复制"];
        }
    }
}

#pragma mark - EventHandler

- (IBAction)avatarImageViewTouchUp:(id)sender
{
    self.selectedUserID = self.status.user.userID;
    [self performSegueWithIdentifier:@"StatusToUserSegue" sender:nil];
}

- (IBAction)contentImageViewTouchUp:(id)sender
{
    if (!self.imageViewController){
        self.imageViewController = [[URBMediaFocusViewController alloc] init];
        self.imageViewController.shouldDismissOnImageTap = YES;
    }
    NSURL *imageURL = [NSURL URLWithString:self.status.photo.largeURL];
    [self.imageViewController showImageFromURL:imageURL fromView:self.view];
}

- (IBAction)replyButtonTouchUp:(id)sender
{
    [self performSegueWithIdentifier:@"StatusToComposeNavigationSegue" sender:sender];
}

- (IBAction)repostButtonTouchUp:(id)sender
{
    [self performSegueWithIdentifier:@"StatusToComposeNavigationSegue" sender:sender];
}

- (IBAction)starButtonTouchUp:(id)sender
{
    [SAMessageDisplayUtils showProgressWithMessage:@"请稍后"];
    if ([self.status.favorited isEqualToNumber:@(YES)]) {
        [[SAAPIService sharedSingleton] deleteFavoriteStatusWithID:self.statusID success:^(id data) {
            self.status.favorited = @(NO);
            [SAMessageDisplayUtils showInfoWithMessage:@"取消收藏成功"];
            [self updateStarButton];
        } failure:^(NSString *error) {
            [SAMessageDisplayUtils showErrorWithMessage:error];
        }];
    } else {
        [[SAAPIService sharedSingleton] createFavoriteStatusWithID:self.statusID success:^(id data) {
            self.status.favorited = @(YES);
            [SAMessageDisplayUtils showInfoWithMessage:@"收藏成功"];
            [self updateStarButton];
        } failure:^(NSString *error) {
            [SAMessageDisplayUtils showErrorWithMessage:error];
        }];
    }
}

- (IBAction)moreButtonTouchUp:(id)sender
{
    SAUser *currentUser = [SADataManager sharedManager].currentUser;
    UIActionSheet *actionSheet;
    if ([self.status.user.userID isEqualToString:currentUser.userID]) {
        actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate: self cancelButtonTitle:@"取消" destructiveButtonTitle:@"删除消息" otherButtonTitles:@"复制消息", nil];
        actionSheet.tag = 2;
    } else {
        actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate: self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"复制消息", nil];
        actionSheet.tag = 1;
    }
    [actionSheet showInView:self.view];
}

- (void)linkButtonTouchUp:(DTLinkButton *)sender
{
    NSURL *URL = sender.URL;
    if ([URL.host isEqualToString:@"fanfou.com"]) {
        self.selectedUserID = URL.lastPathComponent;
        [self performSegueWithIdentifier:@"StatusToUserSegue" sender:nil];
    } else if ([URL.scheme isEqualToString:@"http"] || [URL.scheme isEqualToString:@"https"]) {
        [[UIApplication sharedApplication] openURL:URL];
    }
}

@end
