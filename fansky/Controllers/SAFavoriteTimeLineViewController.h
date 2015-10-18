//
//  SAFavoriteTimeLineViewController.h
//  fansky
//
//  Created by Zzy on 10/18/15.
//  Copyright © 2015 Zzy. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <ARSegmentPager/ARSegmentControllerDelegate.h>

@interface SAFavoriteTimeLineViewController : UITableViewController <ARSegmentControllerDelegate>

@property (copy, nonatomic) NSString *userID;

@end
