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
#import <ARSegmentPager/ARSegmentPageController.h>

//void *SAUserHeaderViewInsetObserver = &SAUserHeaderViewInsetObserver;

@interface SAUserViewController ()

@property (strong, nonatomic) SAUser *user;

@end

@implementation SAUserViewController

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"SAMain" bundle:[NSBundle mainBundle]];
    SATimeLineViewController *timeLineViewController = [storyboard instantiateViewControllerWithIdentifier:@"SATimeLineViewController"];
    self = [super initWithControllers:timeLineViewController, timeLineViewController, nil];
    if (self) {
        self.headerHeight = 130;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    SATimeLineViewController *timeLineViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"SATimeLineViewController"];
    [self setViewControllers:@[timeLineViewController]];
    
//    [self addObserver:self forKeyPath:@"segmentToInset" options:NSKeyValueObservingOptionNew context:SAUserHeaderViewInsetObserver];
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
    [self removeObserver:self forKeyPath:@"segmentToInset"];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
