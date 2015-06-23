//
//  SALoginViewController.m
//  fansky
//
//  Created by Zzy on 6/17/15.
//  Copyright (c) 2015 Zzy. All rights reserved.
//

#import "SALoginViewController.h"
#import "SAUserManager.h"

@interface SALoginViewController () <UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITextField *usernameTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property (weak, nonatomic) IBOutlet UIButton *loginButton;

@end

@implementation SALoginViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.loginButton.layer.borderColor = [UIColor colorWithRed:0 green:122 / 255.0f blue:1 alpha:1].CGColor;
}

- (void)startAuth
{
    [[SAUserManager manager] authWithUsername:self.usernameTextField.text password:self.passwordTextField.text success:^{
        NSLog(@"======");
        [self performSegueWithIdentifier:@"LoginExitToSplashSegue" sender:nil];
    } failure:^(NSError *error) {
        NSLog(@"%@", error);
    }];
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField.tag == 1) {
        [self.passwordTextField becomeFirstResponder];
    } else if (textField.tag == 2) {
        [self startAuth];
    }
    return YES;
}

- (IBAction)loginButtonClick:(id)sender
{
    [self startAuth];
}

@end
