//
//  SAUser.h
//  fansky
//
//  Created by Zzy on 9/11/15.
//  Copyright (c) 2015 Zzy. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface SAUser : NSManagedObject

@property (nonatomic, retain) NSNumber * active;
@property (nonatomic, retain) NSNumber * local;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * token;
@property (nonatomic, retain) NSString * tokenSecret;
@property (nonatomic, retain) NSString * userID;
@property (nonatomic, retain) NSString * profileImageURL;
@property (nonatomic, retain) NSString * location;

@end
