//
//  SAStatus+CoreDataProperties.h
//  fansky
//
//  Created by Zzy on 9/18/15.
//  Copyright © 2015 Zzy. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "SAStatus.h"

NS_ASSUME_NONNULL_BEGIN

@interface SAStatus (CoreDataProperties)

@property (nullable, nonatomic, retain) NSDate *createdAt;
@property (nullable, nonatomic, retain) NSNumber *homeLine;
@property (nullable, nonatomic, retain) NSString *source;
@property (nullable, nonatomic, retain) NSString *statusID;
@property (nullable, nonatomic, retain) NSString *text;
@property (nullable, nonatomic, retain) NSNumber *mention;
@property (nullable, nonatomic, retain) SAUser *localUser;
@property (nullable, nonatomic, retain) SAPhoto *photo;
@property (nullable, nonatomic, retain) SAUser *user;

@end

NS_ASSUME_NONNULL_END
