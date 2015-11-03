//
//  UIColor+Utils.m
//  fansky
//
//  Created by Zzy on 11/1/15.
//  Copyright © 2015 Zzy. All rights reserved.
//

#import "UIColor+Utils.h"

@implementation UIColor (Utils)

+ (UIColor *)fanskyBlue
{
    static UIColor *color;
    static dispatch_once_t token = 0;
    dispatch_once(&token, ^{
        if (!color) {
            color = [UIColor colorWithRed:85 / 255.0 green:172 / 255.0 blue:238 / 255.0 alpha:1];
        }
    });
    return color;
}

@end
