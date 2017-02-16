//
//  SAPresentationAnimator.m
//  fansky
//
//  Created by Zzy on 2/16/17.
//  Copyright © 2017 Zzy. All rights reserved.
//

#import "SAPresentationAnimator.h"
#import "SAUserInfoViewController.h"

@implementation SAPresentationAnimator

-(NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext {
    return 0.3;
}

-(void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext {
    SAUserInfoViewController *destinationViewController = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    
    destinationViewController.blurView.effect = nil;
    destinationViewController.infoLabel.alpha = 0;
    destinationViewController.closeButton.alpha = 0;
    
    UIView *container = [transitionContext containerView];
    [container addSubview:destinationViewController.view];
    
    [UIView animateWithDuration:0.3 animations:^{
        destinationViewController.blurView.effect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
        destinationViewController.infoLabel.alpha = 1;
        destinationViewController.closeButton.alpha = 1;
    } completion:^(BOOL finished) {
        [transitionContext completeTransition:finished];
    }];
}

@end
