//
//  SAComposeViewController.m
//  fansky
//
//  Created by Zzy on 9/14/15.
//  Copyright (c) 2015 Zzy. All rights reserved.
//

#import "SAComposeViewController.h"
#import "SADataManager+User.h"
#import "SAUser.h"
#import "SAAPIService.h"
#import <SDWebImage/UIImageView+WebCache.h>

@interface SAComposeViewController () <UITextViewDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *avatarImageView;
@property (weak, nonatomic) IBOutlet UILabel *placeholderLabel;
@property (weak, nonatomic) IBOutlet UITextView *contentTextView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *functionViewBottomConstraint;

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
}

- (void)viewWillDisappear:(BOOL)animated
{
    [self.view endEditing:YES];
    [super viewWillDisappear:animated];
}

- (void)updateInterface
{
    SAUser *currentUser = [SADataManager sharedManager].currentUser;
    [self.avatarImageView sd_setImageWithURL:[NSURL URLWithString:currentUser.profileImageURL]];
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

#pragma mark - UITextViewDelegate

- (void)textViewDidChange:(UITextView *)textView
{
    if (textView.text.length) {
        self.placeholderLabel.hidden = YES;
    } else {
        self.placeholderLabel.hidden = NO;
    }
}

#pragma mark - EventHandler

- (IBAction)cameraButtonTouchUp:(id)sender
{
}

- (IBAction)sendButtonTouchUp:(id)sender
{
    [[SAAPIService sharedSingleton] sendStatus:self.contentTextView.text replyToStatusID:nil repostStatusID:nil success:^(id data) {
        NSString *error = [data objectForKey:@"error"];
        if (!error) {
            [self performSegueWithIdentifier:@"ComposeExitToTabBarSegue" sender:nil];
        } else {

        }
    } failure:^(NSString *error) {
        
    }];
}


@end
