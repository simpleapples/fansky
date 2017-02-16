//
//  SADismissAnimator.m
//  fansky
//
//  Created by Zzy on 2/16/17.
//  Copyright © 2017 Zzy. All rights reserved.
//

#import "SADismissAnimator.h"
#import "SAUserInfoViewController.h"

@implementation SADismissAnimator

-(NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext {
    return 0.3;
}

-(void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext {
    SAUserInfoViewController *sourceViewController = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    
    UIView *container = [transitionContext containerView];
    UIView *toView = [transitionContext viewForKey:UITransitionContextToViewKey];
    [container addSubview:toView];
    
    [UIView animateWithDuration:0.3 animations:^{
        sourceViewController.blurView.effect = nil;
        sourceViewController.infoLabel.alpha = 0;
        sourceViewController.closeButton.alpha = 0;
    } completion:^(BOOL finished) {
        [transitionContext completeTransition:finished];
    }];
}

@end
