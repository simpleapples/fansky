//
//  SAComposeViewController.h
//  fansky
//
//  Created by Zzy on 9/14/15.
//  Copyright (c) 2015 Zzy. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SAComposeViewController : UIViewController

@property (copy, nonatomic) NSString *userID;
@property (copy, nonatomic) NSString *replyToStatusID;
@property (copy, nonatomic) NSString *repostStatusID;

@end
