//
//  SAPhotoTimeLineViewController.h
//  fansky
//
//  Created by Zzy on 9/17/15.
//  Copyright (c) 2015 Zzy. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <ARSegmentPager/ARSegmentControllerDelegate.h>

@interface SAPhotoTimeLineViewController : UICollectionViewController <ARSegmentControllerDelegate>

@property (copy, nonatomic) NSString *userID;

@end
