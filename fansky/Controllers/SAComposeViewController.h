//
//  SAComposeViewController.h
//  fansky
//
//  Created by Zzy on 9/14/15.
//  Copyright (c) 2015 Zzy. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SAStatus;

@interface SAComposeViewController : UIViewController

@property (copy, nonatomic) NSString *userID;
@property (strong, nonatomic) SAStatus *replyToStatus;
@property (strong, nonatomic) SAStatus *repostStatus;

@end
