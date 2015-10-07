//
//  SAComposeViewController.m
//  fansky
//
//  Created by Zzy on 9/14/15.
//  Copyright (c) 2015 Zzy. All rights reserved.
//

#import "SAComposeViewController.h"
#import "SADataManager+User.h"
#import "SADataManager+Status.h"
#import "SAUser+CoreDataProperties.h"
#import "SAStatus+CoreDataProperties.h"
#import "SAAPIService.h"
#import "SAMessageDisplayUtils.h"
#import "NSString+Utils.h"
#import <SDWebImage/UIImageView+WebCache.h>

@interface SAComposeViewController () <UITextViewDelegate, UIActionSheetDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *avatarImageView;
@property (weak, nonatomic) IBOutlet UILabel *placeholderLabel;
@property (weak, nonatomic) IBOutlet UITextView *contentTextView;
@property (weak, nonatomic) IBOutlet UIButton *cameraButton;
@property (weak, nonatomic) IBOutlet UILabel *remainLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *functionViewBottomConstraint;

@property (strong, nonatomic) UIImage *uploadImage;

@end

@implementation SAComposeViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self updateInterface];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShowNotification:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHideNotification:) name:UIKeyboardWillHideNotification object:nil];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.contentTextView becomeFirstResponder];
    [self updateRemainLabel];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [self.view endEditing:YES];
    [super viewWillDisappear:animated];
}

- (void)updateRemainLabel
{
    if (self.contentTextView.text.length > 140) {
        self.remainLabel.text = [NSString stringWithFormat:@"超出%zd字", self.contentTextView.text.length - 140];
    } else {
        self.remainLabel.text = [NSString stringWithFormat:@"剩余%zd字", 140 - self.contentTextView.text.length];
    }
}

- (void)updateInterface
{
    SAUser *currentUser = [SADataManager sharedManager].currentUser;
    [self.avatarImageView sd_setImageWithURL:[NSURL URLWithString:currentUser.profileImageURL]];
    
    if (self.replyToStatusID) {
        self.cameraButton.hidden = YES;
        self.placeholderLabel.hidden = YES;
        SAStatus *status = [[SADataManager sharedManager] statusWithID:self.replyToStatusID];
        self.contentTextView.text = [NSString stringWithFormat:@"@%@ ", status.user.name];
    }
    if (self.repostStatusID) {
        self.cameraButton.hidden = YES;
        self.placeholderLabel.hidden = YES;
        SAStatus *status = [[SADataManager sharedManager] statusWithID:self.repostStatusID];
        self.contentTextView.text = [NSString stringWithFormat:@"「@%@ %@」", status.user.name, [status.text flattenHTML]];
        self.contentTextView.selectedRange = NSMakeRange(0, 0);
    }
}

- (void)send
{
    NSData *imageData = UIImageJPEGRepresentation(self.uploadImage, 0.5);
    [SAMessageDisplayUtils showProgressWithMessage:@"正在发送"];
    [[SAAPIService sharedSingleton] sendStatus:self.contentTextView.text replyToStatusID:self.replyToStatusID repostStatusID:self.repostStatusID image:imageData success:^(id data) {
        [SAMessageDisplayUtils showSuccessWithMessage:@"发送完成"];
        SAUser *currentUser = [SADataManager sharedManager].currentUser;
        [[SADataManager sharedManager] insertOrUpdateStatusWithObject:data localUser:currentUser type:(SAStatusTypeTimeLine & SAStatusTypeUserStatus)];
        [self dismissViewControllerAnimated:YES completion:nil];
    } failure:^(NSString *error) {
        [SAMessageDisplayUtils showErrorWithMessage:error];
    }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - KeyboardNotification

- (void)keyboardWillShowNotification:(NSNotification *)notification
{
    CGRect keyboardRect = [[notification.userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    CGFloat duration;
    UIViewAnimationCurve curve;
    [[notification.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] getValue:&duration];
    [[notification.userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey] getValue:&curve];
    UIViewAnimationOptions option = curve << 16;
    if (keyboardRect.size.height == 0) {
        return;
    }
    [UIView animateWithDuration:duration delay:0.0f options:option animations:^{
        self.functionViewBottomConstraint.constant = keyboardRect.size.height;
    } completion:nil];
}

- (void)keyboardWillHideNotification:(NSNotification *)notification
{
    CGFloat duration;
    UIViewAnimationCurve curve;
    [[notification.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] getValue:&duration];
    [[notification.userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey] getValue:&curve];
    UIViewAnimationOptions option = curve << 16;
    [UIView animateWithDuration:duration delay:0.0f options:option animations:^{
        self.functionViewBottomConstraint.constant = 0;
    } completion:nil];
}

#pragma mark - UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (actionSheet.tag == 1) {
        UIImagePickerControllerSourceType type;
        if (buttonIndex == 0 && [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
            type = UIImagePickerControllerSourceTypeCamera;
        } else if (buttonIndex == 1 && [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) {
            type = UIImagePickerControllerSourceTypePhotoLibrary;
        } else {
            [self.contentTextView becomeFirstResponder];
            return;
        }
        [self.view endEditing:YES];
        UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
        imagePickerController.delegate = self;
        imagePickerController.allowsEditing = NO;
        imagePickerController.sourceType = type;
        [self presentViewController:imagePickerController animated:YES completion:nil];
    } else if (actionSheet.tag == 2) {
        if (buttonIndex == 0) {
            [self dismissViewControllerAnimated:YES completion:nil];
        } else {
            [self.contentTextView becomeFirstResponder];
        }
    } else if (actionSheet.tag == 3) {
        if (buttonIndex == 0) {
            [self send];
        } else {
            [self.contentTextView becomeFirstResponder];
        }
    }
}

#pragma mark - UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    [picker dismissViewControllerAnimated:YES completion:nil];
    self.uploadImage = [info objectForKey:UIImagePickerControllerOriginalImage];
    [self.cameraButton setImage:[UIImage imageNamed:@"IconCameraCheck"] forState:UIControlStateNormal];
}

-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - UITextViewDelegate

- (void)textViewDidChange:(UITextView *)textView
{
    if (textView.text.length) {
        self.placeholderLabel.hidden = YES;
    } else {
        self.placeholderLabel.hidden = NO;
    }
    [self updateRemainLabel];
}

#pragma mark - EventHandler

- (IBAction)cameraButtonTouchUp:(id)sender
{
    [self.view endEditing:YES];
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"拍摄照片", @"从相册中选择", nil];
    actionSheet.tag = 1;
    [actionSheet showInView:self.view];
}

- (IBAction)sendButtonTouchUp:(id)sender
{
    if (!self.contentTextView.text.length) {
        [SAMessageDisplayUtils showInfoWithMessage:@"说点什么吧"];
        return;
    } else if (self.contentTextView.text.length > 140) {
        [self.view endEditing:YES];
        UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"超出140个字符部分将被丢弃" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:@"继续发送" otherButtonTitles:nil];
        actionSheet.tag = 3;
        [actionSheet showInView:self.view];
    } else {
        [self send];
    }
}

- (IBAction)closeButtonTouchUp:(id)sender
{
    if (self.contentTextView.text.length) {
        [self.view endEditing:YES];
        UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:@"放弃更改" otherButtonTitles: nil];
        actionSheet.tag = 2;
        [actionSheet showInView:self.view];
    } else {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

@end
