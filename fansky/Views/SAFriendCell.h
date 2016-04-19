//
//  SAFriendCell.h
//  fansky
//
//  Created by Zzy on 9/25/15.
//  Copyright © 2015 Zzy. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, SAFriendCellType)
{
    SAFriendCellTypeFollow,
    SAFriendCellTypeFriend,
    SAFriendCellTypeFriendPopup,
    SAFriendCellTypeRequest
};

@class SAFriend;

@interface SAFriendCell : UITableViewCell

- (void)configWithFriend:(SAFriend *)friend type:(SAFriendCellType)type;
- (void)loadImage;

@end
