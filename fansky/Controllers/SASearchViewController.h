//
//  SASearchViewController.h
//  fansky
//
//  Created by Zzy on 10/27/15.
//  Copyright © 2015 Zzy. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, SASearchViewControllerType)
{
    SASearchViewControllerTypeTrend = 1,
    SASearchViewControllerTypeSearch = 2,
    SASearchViewControllerTypeRandom = 3
};

@interface SASearchViewController : UIViewController

@property (nonatomic) SASearchViewControllerType type;
@property (copy, nonatomic) NSString *keyword;

@end
