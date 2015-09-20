//
//  SATimeLinePhotoCell.h
//  fansky
//
//  Created by Zzy on 9/18/15.
//  Copyright © 2015 Zzy. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SAStatus;
@class SATimeLinePhotoCell;

@protocol SATimeLinePhotoCellDelegate <NSObject>

- (void)timeLinePhotoCell:(SATimeLinePhotoCell *)timeLineCell avatarImageViewTouchUp:(id)sender;
- (void)timeLinePhotoCell:(SATimeLinePhotoCell *)timeLineCell contentImageViewTouchUp:(id)sender;
- (void)timeLinePhotoCell:(SATimeLinePhotoCell *)timeLineCell contentURLTouchUp:(id)sender;

@end

@interface SATimeLinePhotoCell : UITableViewCell

@property (weak, nonatomic) id<SATimeLinePhotoCellDelegate> delegate;
@property (weak, nonatomic) SAStatus *status;
@property (strong, nonatomic) NSURL *selectedURL;

- (void)configWithStatus:(SAStatus *)status;
- (void)loadAllImages;

@end
