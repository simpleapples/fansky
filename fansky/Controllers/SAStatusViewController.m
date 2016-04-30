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
#import "SAPhotoPreviewViewController.h"
#import "NSDate+Utils.h"
#import "NSString+Utils.h"
#import "UIColor+Utils.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import <DTCoreText/DTCoreText.h>
#import <MobileCoreServices/UTCoreTypes.h>
#import <JTSImageViewController/JTSImageViewController.h>

@interface SAStatusViewController () <DTAttributedTextContentViewDelegate, JTSImageViewControllerInteractionsDelegate, UIViewControllerPreviewingDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *avatarImageView;
@property (weak, nonatomic) IBOutlet UILabel *usernameLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet DTAttributedLabel *contentLabel;
@property (weak, nonatomic) IBOutlet UIImageView *contentImageView;
@property (weak, nonatomic) IBOutlet UIImageView *iconGIFImageView;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *starButton;
@property (weak, nonatomic) IBOutlet UIButton *originalStatusButton;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *timeLabelTopToLabelMarginConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *timeLabelTopToImageViewMarginConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *contentLabelHeightConstraint;

@property (copy, nonatomic) NSString *selectedUserID;
@property (strong, nonatomic) SAStatus *replyStatus;

@end

@implementation SAStatusViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self updateInterface];
    
    if (self.status.replyStatusID.length) {
        [[SAAPIService sharedSingleton] showStatusWithID:self.status.replyStatusID success:^(id data) {
            self.replyStatus = [[SADataManager sharedManager] statusWithObject:data localUsers:nil type:SAStatusTypeUserStatus];
            if (self.replyStatus.statusID.length) {
                NSString *buttonTitle = [NSString stringWithFormat:@"回复给 %@", self.replyStatus.user.name];
                [self.originalStatusButton setTitle:buttonTitle forState:UIControlStateNormal];
                self.originalStatusButton.hidden = NO;
            }
        } failure:nil];
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [SAMessageDisplayUtils dismiss];
    [super viewWillDisappear:animated];
}

- (void)updateStarButton
{
    if ([self.status.isFavorited isEqualToNumber:@(YES)]) {
        [self.starButton setImage:[UIImage imageNamed:@"IconStarSelected"]];
    } else {
        [self.starButton setImage:[UIImage imageNamed:@"IconStar"]];
    }
}

- (void)updateInterface
{
    [self updateStarButton];
    
    self.avatarImageView.layer.rasterizationScale = [UIScreen mainScreen].scale;
    self.contentImageView.layer.rasterizationScale = [UIScreen mainScreen].scale;
    
    self.usernameLabel.text = self.status.user.name;
    self.timeLabel.text = [NSString stringWithFormat:@"%@ ∙ 通过%@", [self.status.createdAt dateStringWithFormat:@"MM-dd HH:mm"], [self.status.source flattenHTML]];
    [self.avatarImageView sd_setImageWithURL:[NSURL URLWithString:self.status.user.profileImageURL] placeholderImage:[UIImage imageNamed:@"BackgroundAvatar"] options:SDWebImageRefreshCached];
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
    
    if (self.status.photo.largeURL) {
        self.contentImageView.hidden = NO;
        [self.contentImageView sd_setImageWithURL:[NSURL URLWithString:self.status.photo.largeURL] placeholderImage:[UIImage imageNamed:@"BackgroundImage"] options:SDWebImageRefreshCached completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
            if ([self.status.photo.largeURL hasSuffix:@".gif"]) {
                self.iconGIFImageView.hidden = NO;
                self.contentImageView.image = image.images.firstObject;
            }
        }];
        self.timeLabelTopToImageViewMarginConstraint.priority = UILayoutPriorityRequired;
    } else {
        self.contentImageView.hidden = YES;
        self.timeLabelTopToLabelMarginConstraint.priority = UILayoutPriorityRequired;
    }
    
    if (self.traitCollection.forceTouchCapability == UIForceTouchCapabilityAvailable) {
        [self registerForPreviewingWithDelegate:self sourceView:self.view];
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
            UIBarButtonItem *barButton = (UIBarButtonItem *)sender;
            if (barButton.tag == 1) {
                composeViewController.replyToStatusID = self.status.statusID;
            } else if (barButton.tag == 2) {
                composeViewController.repostStatusID = self.status.statusID;
            }
        }
    }
}

- (void)showPhoto
{
    UIImage *image = [[SDImageCache sharedImageCache] imageFromDiskCacheForKey:self.status.photo.largeURL];
    
    JTSImageInfo *imageInfo = [[JTSImageInfo alloc] init];
    if (image) {
        imageInfo.image = image;
    } else {
        imageInfo.imageURL = [NSURL URLWithString:self.status.photo.largeURL];
    }
    imageInfo.referenceRect = self.contentImageView.frame;
    imageInfo.referenceView = self.contentImageView.superview;
    
    JTSImageViewController *imageViewer = [[JTSImageViewController alloc] initWithImageInfo:imageInfo mode:JTSImageViewControllerMode_Image backgroundStyle:(JTSImageViewControllerBackgroundOption_Scaled | JTSImageViewControllerBackgroundOption_Blurred)];
    imageViewer.interactionsDelegate = self;
    [imageViewer showFromViewController:self transition:JTSImageViewControllerTransition_FromOriginalPosition];
}

- (UIImage *)shareImage
{
    
    CGFloat width = [UIScreen mainScreen].bounds.size.width;
    CGFloat height = self.usernameLabel.frame.size.height + self.contentLabel.frame.size.height + 16 + 10 + 16 + 20 + 20;
    
    CGFloat imageHeight = 0;
    if (self.contentImageView.image) {
        imageHeight = self.contentImageView.image.size.height / self.contentImageView.image.size.width * self.contentImageView.frame.size.width;
        height += (imageHeight + 10);
    }
    CGSize imageSize = CGSizeMake(width, height);
    UIGraphicsBeginImageContextWithOptions(imageSize, NO, 0.0);
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGContextSetCharacterSpacing(ctx, 10);
    CGContextSetTextDrawingMode(ctx, kCGTextFillStroke);
    CGContextSetRGBFillColor(ctx, 0, 0, 0, 1);
    
    [self.avatarImageView drawViewHierarchyInRect:self.avatarImageView.frame afterScreenUpdates:YES];
    [self.usernameLabel drawViewHierarchyInRect:self.usernameLabel.frame afterScreenUpdates:YES];
    [self.contentLabel drawViewHierarchyInRect:self.contentLabel.frame afterScreenUpdates:YES];
    
    if (self.contentImageView.image) {
        [self.contentImageView.image drawInRect:CGRectMake(self.contentImageView.frame.origin.x, self.contentImageView.frame.origin.y, self.contentImageView.frame.size.width, imageHeight)];
    }
    
    UIImage *shareContentImage = [UIImage imageNamed:@"IconShareContent"];
    [shareContentImage drawInRect:CGRectMake(self.contentLabel.frame.origin.x, height - 20 - 20, shareContentImage.size.width, shareContentImage.size.height)];
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo
{
    if (error) {
        [SAMessageDisplayUtils showErrorWithMessage:@"保存失败"];
    } else {
        [SAMessageDisplayUtils showSuccessWithMessage:@"已保存到相册"];
    }
}

#pragma mark - UIViewControllerPreviewingDelegate

- (UIViewController *)previewingContext:(id<UIViewControllerPreviewing>)previewingContext viewControllerForLocation:(CGPoint)location
{
    CGRect sourceRect = CGRectZero;
    if (self.status.photo.largeURL) {
        CGPoint imageOrigin = self.contentImageView.frame.origin;
        CGSize imageSize = self.contentImageView.frame.size;
        if (location.x >= imageOrigin.x && location.x <= imageOrigin.x + imageSize.width && location.y >= imageOrigin.y && location.y <= imageOrigin.y + imageSize.height) {
            sourceRect = self.contentImageView.frame;
        }
    }
    
    if (!CGRectEqualToRect(sourceRect, CGRectZero)) {
        previewingContext.sourceRect = sourceRect;
        
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"SAOthers" bundle:[NSBundle mainBundle]];
        SAPhotoPreviewViewController *photoPreviewViewController = [storyboard instantiateViewControllerWithIdentifier:@"SAPhotoPreviewViewController"];
        photoPreviewViewController.status = self.status;
        return photoPreviewViewController;
    }
    return nil;
}

- (void)previewingContext:(id<UIViewControllerPreviewing>)previewingContext commitViewController:(UIViewController *)viewControllerToCommit
{
    [self showPhoto];
}

#pragma mark - JTSImageViewControllerInteractionsDelegate

- (void)imageViewerDidLongPress:(JTSImageViewController *)imageViewer atRect:(CGRect)rect
{
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
    UIAlertAction *saveToAlbumAction = [UIAlertAction actionWithTitle:@"保存到相册" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        UIImageWriteToSavedPhotosAlbum(imageViewer.image, self, @selector(image:didFinishSavingWithError:contextInfo:), NULL);
    }];
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    [alertController addAction:saveToAlbumAction];
    [alertController addAction:cancelAction];
    [imageViewer presentViewController:alertController animated:YES completion:nil];
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
    self.selectedUserID = self.status.user.userID;
    [self performSegueWithIdentifier:@"StatusToUserSegue" sender:nil];
}

- (IBAction)contentImageViewTouchUp:(id)sender
{
    [self showPhoto];
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
    if ([self.status.isFavorited isEqualToNumber:@(YES)]) {
        [[SAAPIService sharedSingleton] deleteFavoriteStatusWithID:self.status.statusID success:^(id data) {
            self.status.isFavorited = @(NO);
            [SAMessageDisplayUtils showInfoWithMessage:@"取消收藏成功"];
            [self updateStarButton];
        } failure:^(NSString *error) {
            [SAMessageDisplayUtils showErrorWithMessage:error];
        }];
    } else {
        [[SAAPIService sharedSingleton] createFavoriteStatusWithID:self.status.statusID success:^(id data) {
            self.status.isFavorited = @(YES);
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
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
    UIAlertAction *copyAction = [UIAlertAction actionWithTitle:@"分享" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        if (self.status.text.length) {
            UIImage *image = [self shareImage];
            UIActivityViewController *activityViewController = [[UIActivityViewController alloc] initWithActivityItems:@[image] applicationActivities:nil];
            [self presentViewController:activityViewController animated:YES completion:nil];
        } else {
            [SAMessageDisplayUtils showInfoWithMessage:@"没有消息内容可以分享"];
        }
    }];
    UIAlertAction *reportAction = [UIAlertAction actionWithTitle:@"举报" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [SAMessageDisplayUtils showSuccessWithMessage:@"已举报"];
    }];
    UIAlertAction *deleteAction = [UIAlertAction actionWithTitle:@"删除消息" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        [[SAAPIService sharedSingleton] deleteStatusWithID:self.status.statusID success:^(id data) {
            [[SADataManager sharedManager] deleteStatusWithID:self.status.statusID];
            [SAMessageDisplayUtils showSuccessWithMessage:@"删除成功"];
            [self.navigationController popViewControllerAnimated:YES];
        } failure:^(NSString *error) {
            [SAMessageDisplayUtils showErrorWithMessage:error];
        }];
    }];
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    if ([self.status.user.userID isEqualToString:currentUser.userID]) {
        [alertController addAction:deleteAction];
    }
    [alertController addAction:copyAction];
    [alertController addAction:reportAction];
    [alertController addAction:cancelAction];
    [self presentViewController:alertController animated:YES completion:nil];
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

- (IBAction)originalStatusButtonTouchUp:(id)sender
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"SAMain" bundle:[NSBundle mainBundle]];
    SAStatusViewController *statusViewController = [storyboard instantiateViewControllerWithIdentifier:@"SAStatusViewController"];
    statusViewController.status = self.replyStatus;
    [self.navigationController showViewController:statusViewController sender:sender];
}

@end
