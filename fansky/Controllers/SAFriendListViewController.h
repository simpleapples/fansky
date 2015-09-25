//
//  SAFriendListViewController.h
//  fansky
//
//  Created by Zzy on 9/25/15.
//  Copyright © 2015 Zzy. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, SAFriendListType)
{
    SAFriendListTypeFollow,
    SAFriendListTypeFriend
};

@interface SAFriendListViewController : UITableViewController

@property (copy, nonatomic) NSString *userID;
@property (assign, nonatomic) SAFriendListType type;

@end
