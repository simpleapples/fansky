//
//  SAUserInfoViewController.m
//  fansky
//
//  Created by Zzy on 10/23/15.
//  Copyright © 2015 Zzy. All rights reserved.
//

#import "SAUserInfoViewController.h"
#import "SAUser+CoreDataProperties.h"
#import "SADataManager+User.h"

@interface SAUserInfoViewController ()

@property (weak, nonatomic) IBOutlet UILabel *infoLabel;

@property (strong, nonatomic) SAUser *user;

@end

@implementation SAUserInfoViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.user = [[SADataManager sharedManager] userWithID:self.userID];
    if (self.user) {
        [self updateInterface];
    }
}

- (void)updateInterface
{
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.lineHeightMultiple = 1.4;
    NSDictionary *attributes = @{NSParagraphStyleAttributeName: paragraphStyle};
    
    self.infoLabel.attributedText = [[NSAttributedString alloc] initWithString:self.user.desc attributes:attributes];
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

#pragma mark - EventHandler

- (IBAction)closeButtonTouchUp:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
