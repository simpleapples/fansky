//
//  SAStatus.h
//  fansky
//
//  Created by Zzy on 9/17/15.
//  Copyright (c) 2015 Zzy. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class SAPhoto, SAUser;

@interface SAStatus : NSManagedObject

@property (nonatomic, retain) NSDate * createdAt;
@property (nonatomic, retain) NSString * source;
@property (nonatomic, retain) NSString * statusID;
@property (nonatomic, retain) NSString * text;
@property (nonatomic, retain) NSNumber * homeLine;
@property (nonatomic, retain) SAUser *localUser;
@property (nonatomic, retain) SAPhoto *photo;
@property (nonatomic, retain) SAUser *user;

@end
