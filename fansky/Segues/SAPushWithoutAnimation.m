//
//  SAPushWithoutAnimation.m
//  fansky
//
//  Created by Zzy on 9/23/15.
//  Copyright © 2015 Zzy. All rights reserved.
//

#import "SAPushWithoutAnimation.h"

@implementation SAPushWithoutAnimation

- (void)perform
{
    UIViewController *sourceViewController = self.sourceViewController;
    UIViewController *destinationViewController = self.destinationViewController;
    
    [sourceViewController.navigationController pushViewController:destinationViewController animated:NO];
}

@end
