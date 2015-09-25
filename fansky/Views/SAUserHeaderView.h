//
//  SAUserHeaderView.h
//  fansky
//
//  Created by Zzy on 9/15/15.
//  Copyright (c) 2015 Zzy. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SAUserHeaderView;

@protocol SAUserHeaderViewDelegate <NSObject>

- (void)userHeaderView:(SAUserHeaderView *)userHeaderView settingButtonTouchUp:(id)sender;
- (void)userHeaderView:(SAUserHeaderView *)userHeaderView friendsCountButtonTouchUp:(id)sender;
- (void)userHeaderView:(SAUserHeaderView *)userHeaderView followersCountButtonTouchUp:(id)sender;
- (void)userHeaderView:(SAUserHeaderView *)userHeaderView detailButtonTouchUp:(id)sender;

@end

@interface SAUserHeaderView : UIView

@property (weak, nonatomic) id<SAUserHeaderViewDelegate> delegate;

- (void)configWithUserID:(NSString *)userID;

@end
