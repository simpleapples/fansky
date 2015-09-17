//
//  SAPhotoTimeLineCell.h
//  fansky
//
//  Created by Zzy on 9/17/15.
//  Copyright (c) 2015 Zzy. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SAStatus;
@class SAPhotoTimeLineCell;

@protocol SAPhotoTimeLineCellDelegate <NSObject>

- (void)photoTimeLineCell:(SAPhotoTimeLineCell *)photoTimeLineCell imageViewTouchUp:(id)sender;

@end

@interface SAPhotoTimeLineCell : UICollectionViewCell

@property (weak, nonatomic) SAStatus *status;
@property (weak, nonatomic) id<SAPhotoTimeLineCellDelegate> delegate;

- (void)configWithStatus:(SAStatus *)status;
- (void)loadImage;

@end
