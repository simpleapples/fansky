//
//  SAUserViewController.m
//  fansky
//
//  Created by Zzy on 9/15/15.
//  Copyright (c) 2015 Zzy. All rights reserved.
//

#import "SAUserViewController.h"
#import "SATimeLineViewController.h"
#import "SAUserHeaderView.h"
#import "SADataManager+User.h"
#import "SAUser.h"
#import <ARSegmentPager/ARSegmentControllerDelegate.h>
#import <ARSegmentPager/ARSegmentView.h>

//void *SAUserHeaderViewInsetObserver = &SAUserHeaderViewInsetObserver;

@interface SAUserViewController ()

@property (strong, nonatomic) SAUser *user;

@end

@implementation SAUserViewController

- (void)viewDidLoad
{
    if (!self.userID) {
        SAUser *currentUser = [SADataManager sharedManager].currentUser;
        self.userID = currentUser.userID;
    }
    
    [self updateInterface];

    [super viewDidLoad];
    
//    [self addObserver:self forKeyPath:@"segmentToInset" options:NSKeyValueObservingOptionNew context:SAUserHeaderViewInsetObserver];
}

- (void)updateInterface
{
    ARSegmentView *segmentView = [self valueForKey:@"segmentView"];
    segmentView.segmentControl.tintColor = [UIColor colorWithRed:85 / 255.0 green:172 / 255.0 blue:238 / 255.0 alpha:1];
    
    self.headerHeight = 100;
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"SAMain" bundle:[NSBundle mainBundle]];
    SATimeLineViewController *timeLineViewController = [storyboard instantiateViewControllerWithIdentifier:@"SATimeLineViewController"];
    timeLineViewController.userID = self.userID;
    [self setViewControllers:@[timeLineViewController]];
}

- (UIView<ARSegmentPageControllerHeaderProtocol> *)customHeaderView
{
    SAUserHeaderView *userHeaderView = [[[NSBundle mainBundle] loadNibNamed:@"SAUserHeaderView" owner:nil options:nil] lastObject];
    [userHeaderView configWithUserID:self.userID];
    return userHeaderView;
}

//-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
//{
//    [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
//    if (context == SAUserHeaderViewInsetObserver) {
//        CGFloat inset = [change[NSKeyValueChangeNewKey] floatValue];
//        NSLog(@"inset is %f",inset);
//        
//    }
//}

-(void)dealloc
{
//    [self removeObserver:self forKeyPath:@"segmentToInset"];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
