//
//  SAUser.h
//  fansky
//
//  Created by Zzy on 9/16/15.
//  Copyright (c) 2015 Zzy. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class SAStatus;

@interface SAUser : NSManagedObject

@property (nonatomic, retain) NSNumber * active;
@property (nonatomic, retain) NSNumber * local;
@property (nonatomic, retain) NSString * location;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * profileImageURL;
@property (nonatomic, retain) NSString * token;
@property (nonatomic, retain) NSString * tokenSecret;
@property (nonatomic, retain) NSString * userID;
@property (nonatomic, retain) NSNumber * friendsCount;
@property (nonatomic, retain) NSNumber * followersCount;
@property (nonatomic, retain) NSNumber * following;
@property (nonatomic, retain) NSSet *status;
@end

@interface SAUser (CoreDataGeneratedAccessors)

- (void)addStatusObject:(SAStatus *)value;
- (void)removeStatusObject:(SAStatus *)value;
- (void)addStatus:(NSSet *)values;
- (void)removeStatus:(NSSet *)values;

@end
