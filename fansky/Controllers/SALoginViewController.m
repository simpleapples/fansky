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

@property (weak, nonatomic) IBOutlet UITextField *usernameTextField;
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
    NSString *username = self.usernameTextField.text;
    NSString *password = self.passwordTextField.text;
    
    [[SAAPIService sharedSingleton] authorizeWithUsername:username password:password success:^(NSString *token) {
        [SSKeychain setPassword:token forService:SA_APP_DOMAIN account:username];
                
        [[SAAPIService sharedSingleton] userInfoWithToken:token success:^(NSString *userInfo) {
            
        } failure:^(NSError *error) {
            
        }];
    } failure:^(NSError *error) {
        
    }];
}

@end
