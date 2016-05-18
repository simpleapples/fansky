//
//  SAAboutViewController.m
//  fansky
//
//  Created by Zzy on 16/5/18.
//  Copyright © 2016年 Zzy. All rights reserved.
//

#import "SAAboutViewController.h"
#import "UIColor+Utils.h"
#import <VTAcknowledgementsViewController/VTAcknowledgementsViewController.h>

@interface SAAboutViewController () <UITextViewDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *logoImageView;
@property (weak, nonatomic) IBOutlet UILabel *versionLabel;
@property (weak, nonatomic) IBOutlet UITextView *introTextView;

@end

@implementation SAAboutViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self updateInterface];
}

- (void)updateInterface
{
    self.logoImageView.layer.borderColor = [UIColor lightGrayColor].CGColor;
        
    NSString *introString = self.introTextView.text;
    NSMutableAttributedString *introAttributedString = [[NSMutableAttributedString alloc] initWithAttributedString:self.introTextView.attributedText];
    [introAttributedString addAttribute:NSLinkAttributeName value:@"fansky://acknowledgements" range:[introString rangeOfString:@"致谢"]];
    [introAttributedString addAttribute:NSLinkAttributeName value:@"fansky://opensource" range:[introString rangeOfString:@"开源" options:NSBackwardsSearch]];
    self.introTextView.attributedText = introAttributedString;

    NSDictionary *linkAttributes = @{NSForegroundColorAttributeName: [UIColor fanskyBlue],
                                     NSUnderlineColorAttributeName: [UIColor fanskyBlue],
                                     NSUnderlineStyleAttributeName: @(NSUnderlineStyleSingle)};
    self.introTextView.linkTextAttributes = linkAttributes;
    
    NSDictionary *info = [[NSBundle mainBundle] infoDictionary];
    NSString *versionString = [NSString stringWithFormat:@"饭斯基 %@ (%@)", [info objectForKey:@"CFBundleShortVersionString"], [info objectForKey:@"CFBundleVersion"]];
    self.versionLabel.text = versionString;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - UITextViewDelegate

- (BOOL)textView:(UITextView *)textView shouldInteractWithURL:(NSURL *)URL inRange:(NSRange)characterRange
{
    if ([URL.absoluteString isEqualToString:@"fansky://acknowledgements"]) {
        NSString *path = [[NSBundle mainBundle] pathForResource:@"Pods-fansky-acknowledgements" ofType:@"plist"];
        VTAcknowledgementsViewController *acknowledgementViewController = [[VTAcknowledgementsViewController alloc] initWithAcknowledgementsPlistPath:path];
        acknowledgementViewController.title = @"致谢";
        acknowledgementViewController.headerText = @"饭斯基使用了如下开源组件";
        acknowledgementViewController.footerText = @"使用 CocoaPods 生成";
        [self.navigationController showViewController:acknowledgementViewController sender:nil];
    } else if ([URL.absoluteString isEqualToString:@"fansky://opensource"]) {
        NSURL *fanskyURL = [NSURL URLWithString:@"https://github.com/simpleapples/fansky"];
        [[UIApplication sharedApplication] openURL:fanskyURL];
    }
    return YES;
}

@end
