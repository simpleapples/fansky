//
//  SAMessageDisplayUtils.m
//  fansky
//
//  Created by Zzy on 9/17/15.
//  Copyright © 2015 Zzy. All rights reserved.
//

#import "SAMessageDisplayUtils.h"
#import <JDStatusBarNotification/JDStatusBarNotification.h>

@implementation SAMessageDisplayUtils

+ (void)initialize
{
    [JDStatusBarNotification addStyleNamed:@"SAErrorMessage" prepare:^JDStatusBarStyle *(JDStatusBarStyle *style) {
        style.barColor = [UIColor colorWithRed:190 / 255.0 green:25 / 255.0 blue:49 / 255.0 alpha:1];
        style.textColor = [UIColor whiteColor];
        return style;
    }];
    [JDStatusBarNotification addStyleNamed:@"SASuccessMessage" prepare:^JDStatusBarStyle *(JDStatusBarStyle *style) {
        style.barColor = [UIColor colorWithRed:119 / 255.0 green:178 / 255.0 blue:85 / 255.0 alpha:1];
        style.textColor = [UIColor whiteColor];
        return style;
    }];
    [JDStatusBarNotification addStyleNamed:@"SAActivityIndicatorMessage" prepare:^JDStatusBarStyle *(JDStatusBarStyle *style) {
        style.barColor = [UIColor colorWithRed:85 / 255.0 green:172 / 255.0 blue:238 / 255.0 alpha:1];
        style.textColor = [UIColor whiteColor];
        return style;
    }];
    [JDStatusBarNotification addStyleNamed:@"SAInfoMessage" prepare:^JDStatusBarStyle *(JDStatusBarStyle *style) {
        style.barColor = [UIColor colorWithRed:85 / 255.0 green:172 / 255.0 blue:238 / 255.0 alpha:1];
        style.textColor = [UIColor whiteColor];
        return style;
    }];
}

+ (void)showInfoWithMessage:(NSString *)message
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [JDStatusBarNotification showWithStatus:message dismissAfter:2 styleName:@"SAInfoMessage"];
    });
}

+ (void)showActivityIndicatorWithMessage:(NSString *)message
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [JDStatusBarNotification showWithStatus:message styleName:@"SAActivityIndicatorMessage"];
        [JDStatusBarNotification showActivityIndicator:YES indicatorStyle:UIActivityIndicatorViewStyleWhite];
    });
}

+ (void)showSuccessWithMessage:(NSString *)message
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [JDStatusBarNotification showWithStatus:message dismissAfter:2 styleName:@"SASuccessMessage"];
    });
}

+ (void)showErrorWithMessage:(NSString *)message
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [JDStatusBarNotification showWithStatus:message dismissAfter:2 styleName:@"SAErrorMessage"];
    });
}

+ (void)dismiss
{
    [JDStatusBarNotification dismiss];
}

@end
