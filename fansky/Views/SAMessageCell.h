//
//  SAMessageCell.h
//  fansky
//
//  Created by Zzy on 9/20/15.
//  Copyright © 2015 Zzy. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SAMessage;

@interface SAMessageCell : UITableViewCell

- (void)configWithMessage:(SAMessage *)message;
- (void)loadImage;

@end
