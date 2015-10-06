//
//  SAUser+CoreDataProperties.h
//  fansky
//
//  Created by Zzy on 10/6/15.
//  Copyright © 2015 Zzy. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "SAUser.h"

NS_ASSUME_NONNULL_BEGIN

@interface SAUser (CoreDataProperties)

@property (nullable, nonatomic, retain) NSNumber *active;
@property (nullable, nonatomic, retain) NSNumber *followersCount;
@property (nullable, nonatomic, retain) NSNumber *following;
@property (nullable, nonatomic, retain) NSNumber *friendsCount;
@property (nullable, nonatomic, retain) NSNumber *local;
@property (nullable, nonatomic, retain) NSString *location;
@property (nullable, nonatomic, retain) NSString *name;
@property (nullable, nonatomic, retain) NSString *profileImageURL;
@property (nullable, nonatomic, retain) NSNumber *protected;
@property (nullable, nonatomic, retain) NSString *token;
@property (nullable, nonatomic, retain) NSString *tokenSecret;
@property (nullable, nonatomic, retain) NSString *userID;
@property (nullable, nonatomic, retain) NSNumber *statusCount;
@property (nullable, nonatomic, retain) NSSet<SAStatus *> *status;

@end

@interface SAUser (CoreDataGeneratedAccessors)

- (void)addStatusObject:(SAStatus *)value;
- (void)removeStatusObject:(SAStatus *)value;
- (void)addStatus:(NSSet<SAStatus *> *)values;
- (void)removeStatus:(NSSet<SAStatus *> *)values;

@end

NS_ASSUME_NONNULL_END
