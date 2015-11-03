//
//  SATimeLineCell.h
//  fansky
//
//  Created by Zzy on 9/18/15.
//  Copyright © 2015 Zzy. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SAStatus;
@class SATimeLineCell;

@protocol SATimeLineCellDelegate <NSObject>

- (void)timeLineCell:(SATimeLineCell *)timeLineCell avatarImageViewTouchUp:(id)sender;
- (void)timeLineCell:(SATimeLineCell *)timeLineCell contentImageViewTouchUp:(id)sender;
- (void)timeLineCell:(SATimeLineCell *)timeLineCell contentURLTouchUp:(id)sender;

@end

@interface SATimeLineCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *contentImageView;

@property (weak, nonatomic) id<SATimeLineCellDelegate> delegate;
@property (weak, nonatomic) SAStatus *status;
@property (strong, nonatomic) NSURL *selectedURL;

- (void)configWithStatus:(SAStatus *)status;
- (void)loadAllImages;

@end
