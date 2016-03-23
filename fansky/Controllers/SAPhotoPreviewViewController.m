//
//  SAPhotoPreviewViewController.m
//  fansky
//
//  Created by Zzy on 12/27/15.
//  Copyright © 2015 Zzy. All rights reserved.
//

#import "SAPhotoPreviewViewController.h"
#import "SAStatus.h"
#import "SAUser.h"
#import "SAPhoto.h"
#import "SADataManager+Status.h"
#import "SAMessageDisplayUtils.h"
#import "NSDate+Utils.h"
#import <SDWebImage/UIImageView+WebCache.h>

@interface SAPhotoPreviewViewController ()

@property (weak, nonatomic) IBOutlet UIImageView *avatarImageView;
@property (weak, nonatomic) IBOutlet UILabel *usernameLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UIImageView *contentImageView;

@property (strong, nonatomic) SAStatus *status;

@end

@implementation SAPhotoPreviewViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.status = [[SADataManager sharedManager] statusWithID:self.statusID];
    
    [self updateInterface];
}

- (void)updateInterface
{
    self.usernameLabel.text = self.status.user.name;
    self.timeLabel.text = [self.status.createdAt friendlyDateString];
    [self.avatarImageView sd_setImageWithURL:[NSURL URLWithString:self.status.user.profileImageURL] placeholderImage:[UIImage imageNamed:@"BackgroundAvatar"] options:SDWebImageRefreshCached];
    self.contentImageView.layer.borderColor = [UIColor colorWithWhite:0.9 alpha:1].CGColor;
    
    if (self.status.photo.largeURL) {
        [self.contentImageView sd_setImageWithURL:[NSURL URLWithString:self.status.photo.largeURL] placeholderImage:nil options:SDWebImageRefreshCached];
    }
}

- (NSArray<id<UIPreviewActionItem>> *)previewActionItems
{
    UIPreviewAction *saveToAlbumAction = [UIPreviewAction actionWithTitle:@"保存到相册" style:UIPreviewActionStyleDefault handler:^(UIPreviewAction * _Nonnull action, UIViewController * _Nonnull previewViewController) {
        if (self.contentImageView.image) {
            UIImageWriteToSavedPhotosAlbum(self.contentImageView.image, self, @selector(image:didFinishSavingWithError:contextInfo:), NULL);
        }
    }];
    return @[saveToAlbumAction];
}

- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo
{
    if (error) {
        [SAMessageDisplayUtils showErrorWithMessage:@"保存失败"];
    } else {
        [SAMessageDisplayUtils showSuccessWithMessage:@"已保存到相册"];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
