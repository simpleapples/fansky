//
//  SAModifyInfoViewController.m
//  fansky
//
//  Created by Zzy on 16/4/10.
//  Copyright © 2016年 Zzy. All rights reserved.
//

#import "SAModifyInfoViewController.h"
#import "SAUser+CoreDataProperties.h"
#import "SADataManager+User.h"
#import "SAAPIService.h"
#import "SAMessageDisplayUtils.h"
#import "UIImage+Utils.h"
#import <SDWebImage/UIImageView+WebCache.h>

@interface SAModifyInfoViewController () <UITextViewDelegate, UIImagePickerControllerDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *avatarImageView;
@property (weak, nonatomic) IBOutlet UITextField *locationTextField;
@property (weak, nonatomic) IBOutlet UILabel *briefPlaceholderLabel;
@property (weak, nonatomic) IBOutlet UITextView *briefTextView;

@property (strong, nonatomic) SAUser *user;

@end

@implementation SAModifyInfoViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.user = [SADataManager sharedManager].currentUser;
    
    [self updateInterface];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)updateInterface
{
    self.avatarImageView.layer.rasterizationScale = [UIScreen mainScreen].scale;
    [self updateUserInfo];
}

- (void)updateUserInfo
{
    [self.avatarImageView sd_setImageWithURL:[NSURL URLWithString:self.user.profileImageURL] placeholderImage:[UIImage imageNamed:@"BackgroundAvatar"] options:SDWebImageRefreshCached];
    self.locationTextField.text = self.user.location;
    self.briefTextView.text = self.user.desc;
    [self updateTextView:self.briefTextView];
}

- (void)updateTextView:(UITextView *)textView
{
    if (textView.text.length) {
        self.briefPlaceholderLabel.hidden = YES;
    } else {
        self.briefPlaceholderLabel.hidden = NO;
    }
}

- (void)presentImagePickerControllerWithType:(UIImagePickerControllerSourceType)type
{
    [self.view endEditing:YES];
    UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
    imagePickerController.delegate = self;
    imagePickerController.allowsEditing = NO;
    imagePickerController.sourceType = type;
    [self presentViewController:imagePickerController animated:YES completion:nil];
}

#pragma mark - UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    [picker dismissViewControllerAnimated:YES completion:nil];
    UIImage *tempImage = [info objectForKey:UIImagePickerControllerOriginalImage];
    UIImage *avatarImage = [tempImage fixOrientation];
    NSData *imageData = UIImageJPEGRepresentation(avatarImage, 0.5);
    [SAMessageDisplayUtils showProgressWithMessage:@"头像上传中"];
    [[SAAPIService sharedSingleton] updateProfileWithImage:imageData success:^(id data) {
        self.user.profileImageURL = [data objectForKey:@"profile_image_url_large"];
        [self updateUserInfo];
        [SAMessageDisplayUtils showSuccessWithMessage:@"修改成功"];
    } failure:^(NSString *error) {
        [SAMessageDisplayUtils showErrorWithMessage:error];
    }];
}

-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - UITextViewDelegate

- (void)textViewDidChange:(UITextView *)textView
{
    [self updateTextView:textView];
}

#pragma mark - EventHandler

- (IBAction)cancelButtonTouchUp:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)saveButtonTouchUp:(id)sender
{
    [[SAAPIService sharedSingleton] updateProfileWithLocation:self.locationTextField.text desc:self.briefTextView.text success:^(id data) {
        self.user.desc = [data objectForKey:@"description"];
        self.user.location = [data objectForKey:@"location"];
        [self updateUserInfo];
        [SAMessageDisplayUtils showSuccessWithMessage:@"修改成功"];
        [self dismissViewControllerAnimated:YES completion:nil];
    } failure:^(NSString *error) {
        [SAMessageDisplayUtils showErrorWithMessage:error];
    }];
}

- (IBAction)modifyAvatarButtonTouchUp:(id)sender
{
    [self.view endEditing:YES];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
    UIAlertAction *takePhotoAction = [UIAlertAction actionWithTitle:@"拍摄照片" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
            UIImagePickerControllerSourceType type = UIImagePickerControllerSourceTypeCamera;
            [self presentImagePickerControllerWithType:type];
        }
    }];
    UIAlertAction *choosePhotoAction = [UIAlertAction actionWithTitle:@"从相册选择" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) {
            UIImagePickerControllerSourceType type = UIImagePickerControllerSourceTypePhotoLibrary;
            [self presentImagePickerControllerWithType:type];
        }
    }];
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    [alertController addAction:takePhotoAction];
    [alertController addAction:choosePhotoAction];
    [alertController addAction:cancelAction];
    [self presentViewController:alertController animated:YES completion:nil];
}

@end
