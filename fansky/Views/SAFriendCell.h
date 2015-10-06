//
//  SAFriendCell.h
//  fansky
//
//  Created by Zzy on 9/25/15.
//  Copyright © 2015 Zzy. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SAFriend;

@interface SAFriendCell : UITableViewCell

- (void)configWithFriend:(SAFriend *)friend;
- (void)loadImage;

@end
