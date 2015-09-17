//
//  SALoginViewController.m
//  fansky
//
//  Created by Zzy on 9/10/15.
//  Copyright (c) 2015 Zzy. All rights reserved.
//

#import "SALoginViewController.h"
#import "SAAPIService.h"
#import "SAConstants.h"
#import "SADataManager+User.h"
#import "SAUser.h"
#import "SAMessageDisplayUtils.h"
#import <SSKeychain/SSKeychain.h>

@interface SALoginViewController () <UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITextField *emailTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *loginButton;

@end

@implementation SALoginViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
}

-  (void)viewWillAppear:(BOOL)animated
{
    [self.emailTextField becomeFirstResponder];
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [self.view endEditing:YES];
    [super viewWillDisappear:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)login
{
    self.loginButton.enabled = NO;
    [SAMessageDisplayUtils showActivityIndicatorWithMessage:@"正在登录"];
    
    NSString *email = self.emailTextField.text;
    NSString *password = self.passwordTextField.text;
    
    [[SAAPIService sharedSingleton] authorizeWithUsername:email password:password success:^(NSString *token, NSString *secret) {
        [[SAAPIService sharedSingleton] verifyCredentialsWithToken:token secret:secret success:^(id data) {
            self.loginButton.enabled = YES;
            [SAMessageDisplayUtils showSuccessWithMessage:@"登录成功"];
            [[SADataManager sharedManager] insertOrUpdateUserWithObject:data local:YES active:YES token:token secret:secret];
            [self performSegueWithIdentifier:@"LoginExitToUserListSegue" sender:nil];
        } failure:^(NSString *error) {
            self.loginButton.enabled = YES;
            [SAMessageDisplayUtils showErrorWithMessage:error];
        }];
    } failure:^(NSString *error) {
        self.loginButton.enabled = YES;
        [SAMessageDisplayUtils showErrorWithMessage:error];
    }];
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField.tag == 1) {
        [self.passwordTextField becomeFirstResponder];
    } else if (textField.tag == 2) {
        [self login];
    }
    return YES;
}

#pragma mark - EventHandler

- (IBAction)loginButtonTouchUp:(id)sender
{
    [self login];
}

- (IBAction)cancelButtonTouchUp:(id)sender
{
    [self performSegueWithIdentifier:@"LoginExitToUserListSegue" sender:nil];
}

@end
