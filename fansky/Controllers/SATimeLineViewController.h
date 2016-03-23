//
//  TimeLineViewController.h
//  fansky
//
//  Created by Zzy on 6/17/15.
//  Copyright (c) 2015 Zzy. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <ARSegmentPager/ARSegmentControllerDelegate.h>
#import "LGRefreshView.h"

@class RLMResults;

@interface SATimeLineViewController : UITableViewController <ARSegmentControllerDelegate>

@property (strong, nonatomic) LGRefreshView *refreshView;

@property (strong, nonatomic) RLMResults *timeLineList;
@property (copy, nonatomic) NSString *userID;
@property (copy, nonatomic) NSString *selectedStatusID;
@property (copy, nonatomic) NSString *selectedUserID;

- (void)refreshData;
- (void)getLocalData;
- (void)updateDataWithRefresh:(BOOL)refresh;

@end
