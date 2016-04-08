//
//  SAStatus+CoreDataProperties.h
//  fansky
//
//  Created by Zzy on 16/4/8.
//  Copyright © 2016年 Zzy. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "SAStatus.h"

NS_ASSUME_NONNULL_BEGIN

@interface SAStatus (CoreDataProperties)

@property (nullable, nonatomic, retain) NSDate *createdAt;
@property (nullable, nonatomic, retain) NSNumber *isFavorited;
@property (nullable, nonatomic, retain) NSString *repostStatusID;
@property (nullable, nonatomic, retain) NSString *source;
@property (nullable, nonatomic, retain) NSString *statusID;
@property (nullable, nonatomic, retain) NSString *text;
@property (nullable, nonatomic, retain) NSNumber *type;
@property (nullable, nonatomic, retain) NSString *replyStatusID;
@property (nullable, nonatomic, retain) NSSet<SAUser *> *localUsers;
@property (nullable, nonatomic, retain) SAPhoto *photo;
@property (nullable, nonatomic, retain) SAUser *user;

@end

@interface SAStatus (CoreDataGeneratedAccessors)

- (void)addLocalUsersObject:(SAUser *)value;
- (void)removeLocalUsersObject:(SAUser *)value;
- (void)addLocalUsers:(NSSet<SAUser *> *)values;
- (void)removeLocalUsers:(NSSet<SAUser *> *)values;

@end

NS_ASSUME_NONNULL_END
