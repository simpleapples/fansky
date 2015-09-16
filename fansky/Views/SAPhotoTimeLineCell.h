//
//  SAPhotoTimeLineCell.h
//  fansky
//
//  Created by Zzy on 9/17/15.
//  Copyright (c) 2015 Zzy. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SAStatus;

@interface SAPhotoTimeLineCell : UICollectionViewCell

- (void)configWithStatus:(SAStatus *)status;
- (void)loadImage;

@end
