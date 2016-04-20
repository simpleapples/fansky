//
//  main.m
//  fansky
//
//  Created by Zzy on 6/17/15.
//  Copyright (c) 2015 Zzy. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SAAppDelegate.h"
#import <FBAllocationTracker/FBAllocationTracker.h>
#import <FBRetainCycleDetector/FBRetainCycleDetector.h>

int main(int argc, char * argv[]) {
    [FBAssociationManager hook];
    [[FBAllocationTrackerManager sharedManager] startTrackingAllocations];
    [[FBAllocationTrackerManager sharedManager] enableGenerations];
    
    @autoreleasepool {
        return UIApplicationMain(argc, argv, nil, NSStringFromClass([SAAppDelegate class]));
    }
}
