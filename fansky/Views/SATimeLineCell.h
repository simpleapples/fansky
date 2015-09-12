//
//  SATimeLineCell.h
//  fansky
//
//  Created by Zzy on 6/23/15.
//  Copyright (c) 2015 Zzy. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SAStatus;

@interface SATimeLineCell : UITableViewCell

- (void)configWithStatus:(SAStatus *)status;

@end
