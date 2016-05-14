//
//  SAFriendListViewController.h
//  fansky
//
//  Created by Zzy on 9/25/15.
//  Copyright © 2015 Zzy. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <STPopup/UIViewController+STPopup.h>

typedef NS_ENUM(NSUInteger, SAFriendListType)
{
    SAFriendListTypeFollow,
    SAFriendListTypeFriend,
    SAFriendListTypeFriendPopup,
    SAFriendListTypeRequest
};

@class SAFriendListViewController;
@class SAFriend;

@protocol SAFriendListViewControllerDelegate <NSObject>

- (void)friendListViewController:(SAFriendListViewController *)friendListViewController selectedfriend:(SAFriend *)selectedFriend;

@end

@interface SAFriendListViewController : UITableViewController

@property (weak, nonatomic) id<SAFriendListViewControllerDelegate> delegate;
@property (copy, nonatomic) NSString *userID;
@property (assign, nonatomic) SAFriendListType type;

@end
