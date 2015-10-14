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
#import "TTTAttributedLabel.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import <URBMediaFocusViewController/URBMediaFocusViewController.h>
#import <MobileCoreServices/UTCoreTypes.h>

@interface SAStatusViewController () <TTTAttributedLabelDelegate, UIActionSheetDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *avatarImageView;
@property (weak, nonatomic) IBOutlet UILabel *usernameLabel;
@property (weak, nonatomic) IBOutlet TTTAttributedLabel *contentLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UIImageView *contentImageView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *timeLabelTopToLabelMarginConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *timeLabelTopToImageViewMarginConstraint;
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

- (void)updateInterface
{
    self.usernameLabel.text = self.status.user.name;
    self.contentLabel.text = self.status.text;
    self.timeLabel.text = [NSString stringWithFormat:@"%@ ∙ 通过%@", [self.status.createdAt defaultDateString], [self.status.source flattenHTML]];
    [self.avatarImageView sd_setImageWithURL:[NSURL URLWithString:self.status.user.profileImageURL]];
    self.contentImageView.layer.borderColor = [UIColor colorWithWhite:0.9 alpha:1].CGColor;
    
    NSDictionary *linkAttributesDict = @{NSForegroundColorAttributeName: [UIColor colorWithRed:85 / 255.0 green:172 / 255.0 blue:238 / 255.0 alpha:1], NSUnderlineStyleAttributeName: @(NSUnderlineStyleNone)};
    self.contentLabel.linkAttributes = linkAttributesDict;
    self.contentLabel.activeLinkAttributes = linkAttributesDict;
    self.contentLabel.text = [[NSAttributedString alloc] initWithData:[self.status.text dataUsingEncoding:NSUnicodeStringEncoding] options:@{NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType} documentAttributes:nil error:nil];
    
    UIFont *newFont = [UIFont systemFontOfSize:16];
    NSMutableAttributedString* attributedString = [self.contentLabel.attributedText mutableCopy];
    [attributedString beginEditing];
    [attributedString enumerateAttribute:NSFontAttributeName inRange:NSMakeRange(0, attributedString.length) options:0 usingBlock:^(id value, NSRange range, BOOL *stop) {
        NSMutableParagraphStyle * paragraphStyle = [[NSMutableParagraphStyle alloc] init];
        [paragraphStyle setLineSpacing:12];
        [attributedString addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:range];
        [attributedString removeAttribute:NSFontAttributeName range:range];
        [attributedString addAttribute:NSFontAttributeName value:newFont range:range];
        [attributedString addAttribute:NSUnderlineStyleAttributeName value:@(NSUnderlineStyleNone) range:range];
    }];
    [attributedString endEditing];
    self.contentLabel.text = [attributedString copy];
    self.contentLabel.enabledTextCheckingTypes = NSTextCheckingTypeLink;
    self.contentLabel.delegate = self;
    
    if (self.status.photo.thumbURL) {
        self.contentImageView.hidden = NO;
        [self.contentImageView sd_setImageWithURL:[NSURL URLWithString:self.status.photo.largeURL]];
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

#pragma mark - TTTAttributedLabelDelegate

- (void)attributedLabel:(TTTAttributedLabel *)label didSelectLinkWithURL:(NSURL *)url
{
    if ([url.host isEqualToString:@"fanfou.com"]) {
        self.selectedUserID = url.lastPathComponent;
        [self performSegueWithIdentifier:@"StatusToUserSegue" sender:nil];
    } else if ([url.scheme isEqualToString:@"http"] || [url.scheme isEqualToString:@"https"]) {
        [[UIApplication sharedApplication] openURL:url];
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

@end
