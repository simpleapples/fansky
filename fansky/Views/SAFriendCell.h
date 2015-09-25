//
//  SAFriendCell.h
//  fansky
//
//  Created by Zzy on 9/25/15.
//  Copyright © 2015 Zzy. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SAUser;

@interface SAFriendCell : UITableViewCell

- (void)configWithUser:(SAUser *)user;
- (void)loadImage;

@end
