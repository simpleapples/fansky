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
#import <SSKeychain/SSKeychain.h>

@interface SALoginViewController ()

@property (weak, nonatomic) IBOutlet UITextField *emailTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;

@end

@implementation SALoginViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (IBAction)loginButtonTouchUp:(id)sender
{
    NSString *email = self.emailTextField.text;
    NSString *password = self.passwordTextField.text;
    
    [[SAAPIService sharedSingleton] authorizeWithUsername:email password:password success:^(NSString *token, NSString *secret) {
        [[SAAPIService sharedSingleton] verifyCredentialsWithToken:token secret:secret success:^(id data) {
            [[SADataManager sharedManager] insertOrUpdateUserWithObject:data local:YES active:YES token:token secret:secret];
            [self performSegueWithIdentifier:@"LoginExitToUserListSegue" sender:nil];
        } failure:^(NSError *error) {
            
        }];
    } failure:^(NSError *error) {
        
    }];
}

@end
