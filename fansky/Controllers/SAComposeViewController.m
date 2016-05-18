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
#import "SAFriendListViewController.h"
#import "SAMessageDisplayUtils.h"
#import "SAFriend.h"
#import "NSString+Utils.h"
#import "UIColor+Utils.h"
#import "UIImage+Utils.h"
#import <STPopup/STPopup.h>
#import <SDWebImage/UIImageView+WebCache.h>

@interface SAComposeViewController () <UITextViewDelegate, UIImagePickerControllerDelegate, SAFriendListViewControllerDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *avatarImageView;
@property (weak, nonatomic) IBOutlet UILabel *placeholderLabel;
@property (weak, nonatomic) IBOutlet UITextView *contentTextView;
@property (weak, nonatomic) IBOutlet UIButton *cameraButton;
@property (weak, nonatomic) IBOutlet UILabel *remainLabel;
@property (weak, nonatomic) IBOutlet UIButton *sendButton;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *functionViewBottomConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *atButtonLeftConstraint;

@property (strong, nonatomic) UIImage *uploadImage;
@property (strong, nonatomic) STPopupController *popupViewController;

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
    self.sendButton.layer.borderColor = [UIColor fanskyBlue].CGColor;
    [self.sendButton.layer setRasterizationScale:[UIScreen mainScreen].scale];
    
    SAUser *currentUser = [SADataManager sharedManager].currentUser;
    [self.avatarImageView sd_setImageWithURL:[NSURL URLWithString:currentUser.profileImageURL] placeholderImage:[UIImage imageNamed:@"BackgroundAvatar"] options:SDWebImageRefreshCached];
    
    if (self.userID) {
        self.cameraButton.hidden = NO;
        self.atButtonLeftConstraint.constant = 54;
        self.placeholderLabel.hidden = YES;
        SAUser *user = [[SADataManager sharedManager] userWithID:self.userID];
        self.contentTextView.text = [NSString stringWithFormat:@"@%@ ", user.name];
    } else if (self.replyToStatus) {
        self.cameraButton.hidden = YES;
        self.atButtonLeftConstraint.constant = 10;
        self.placeholderLabel.hidden = YES;
        self.contentTextView.text = [NSString stringWithFormat:@"@%@ ", self.replyToStatus.user.name];
    } else if (self.repostStatus.statusID) {
        self.cameraButton.hidden = YES;
        self.atButtonLeftConstraint.constant = 10;
        self.placeholderLabel.hidden = YES;
        self.contentTextView.text = [NSString stringWithFormat:@"转@%@ %@", self.repostStatus.user.name, [self.repostStatus.text flattenHTML]];
        self.contentTextView.selectedRange = NSMakeRange(0, 0);
    }
}

- (void)send
{
    NSData *imageData;
    if (self.uploadImage) {
        imageData = UIImageJPEGRepresentation(self.uploadImage, 0.5);
    }
    [SAMessageDisplayUtils showProgressWithMessage:@"正在发送"];
    [[SAAPIService sharedSingleton] sendStatus:self.contentTextView.text replyToStatusID:self.replyToStatus.statusID repostStatusID:self.repostStatus.statusID image:imageData success:^(id data) {
        [SAMessageDisplayUtils showSuccessWithMessage:@"发送完成"];
        [self dismissViewControllerAnimated:YES completion:nil];
    } failure:^(NSString *error) {
        [SAMessageDisplayUtils showErrorWithMessage:error];
    }];
}

- (void)updateTextView:(UITextView *)textView
{
    if (textView.text.length) {
        self.placeholderLabel.hidden = YES;
    } else {
        self.placeholderLabel.hidden = NO;
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

- (void)showFriendPopup
{
    SAUser *currentUser = [SADataManager sharedManager].currentUser;
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"SAMine" bundle:[NSBundle mainBundle]];
    SAFriendListViewController *friendListViewController = (SAFriendListViewController *)[storyboard instantiateViewControllerWithIdentifier:@"SAFriendListViewController"];
    friendListViewController.delegate = self;
    friendListViewController.userID = currentUser.userID;
    friendListViewController.type = SAFriendListTypeFriendPopup;
    self.popupViewController = [[STPopupController alloc] initWithRootViewController:friendListViewController];
    [self.popupViewController presentInViewController:self];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - SAFriendListViewControllerDelegate

- (void)friendListViewController:(SAFriendListViewController *)friendListViewController selectedfriend:(SAFriend *)selectedFriend
{
    [self.popupViewController dismiss];
    self.contentTextView.text = [NSString stringWithFormat:@"%@ @%@", self.contentTextView.text, selectedFriend.name];
    [self updateTextView:self.contentTextView];
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
#pragma mark - UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    [picker dismissViewControllerAnimated:YES completion:nil];
    UIImage *tempImage = [info objectForKey:UIImagePickerControllerOriginalImage];
    self.uploadImage = [tempImage fixOrientation];
    [self.cameraButton setImage:[UIImage imageNamed:@"IconCameraCheck"] forState:UIControlStateNormal];
}

-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - UITextViewDelegate

- (void)textViewDidChange:(UITextView *)textView
{
    [self updateTextView:textView];
    [self updateRemainLabel];
}

#pragma mark - EventHandler

- (IBAction)cameraButtonTouchUp:(id)sender
{
    [self.view endEditing:YES];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        [self.contentTextView becomeFirstResponder];
    }];
    UIAlertAction *takePhotoAction = [UIAlertAction actionWithTitle:@"拍摄照片" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
            UIImagePickerControllerSourceType type = UIImagePickerControllerSourceTypeCamera;
            [self presentImagePickerControllerWithType:type];
        } else {
            [self.contentTextView becomeFirstResponder];
            return;
        }
    }];
    UIAlertAction *choosePhotoAction = [UIAlertAction actionWithTitle:@"从相册选择" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) {
            UIImagePickerControllerSourceType type = UIImagePickerControllerSourceTypePhotoLibrary;
            [self presentImagePickerControllerWithType:type];
        } else {
            [self.contentTextView becomeFirstResponder];
            return;
        }
    }];
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    [alertController addAction:takePhotoAction];
    [alertController addAction:choosePhotoAction];
    [alertController addAction:cancelAction];
    [self presentViewController:alertController animated:YES completion:nil];
}

- (IBAction)sendButtonTouchUp:(id)sender
{
    if (!self.contentTextView.text.length) {
        [SAMessageDisplayUtils showInfoWithMessage:@"说点什么吧"];
        return;
    } else if (self.contentTextView.text.length > 140) {
        [self.view endEditing:YES];
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            [self.contentTextView becomeFirstResponder];
        }];
        UIAlertAction *continueSendAction = [UIAlertAction actionWithTitle:@"继续发送" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
            [self send];
        }];
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"超出140个字符部分将被丢弃" message:nil preferredStyle:UIAlertControllerStyleActionSheet];
        [alertController addAction:continueSendAction];
        [alertController addAction:cancelAction];
        [self presentViewController:alertController animated:YES completion:nil];
    } else {
        [self send];
    }
}

- (IBAction)closeButtonTouchUp:(id)sender
{
    if (self.contentTextView.text.length) {
        [self.view endEditing:YES];
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            [self.contentTextView becomeFirstResponder];
        }];
        UIAlertAction *abandonAction = [UIAlertAction actionWithTitle:@"放弃更改" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
            [self dismissViewControllerAnimated:YES completion:nil];
        }];
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
        [alertController addAction:abandonAction];
        [alertController addAction:cancelAction];
        [self presentViewController:alertController animated:YES completion:nil];
    } else {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

- (IBAction)atButtonTouchUp:(id)sender
{
    [self showFriendPopup];
}

@end
