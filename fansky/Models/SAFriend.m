//
//  SAFriend.m
//  fansky
//
//  Created by Zzy on 10/7/15.
//  Copyright © 2015 Zzy. All rights reserved.
//

#import "SAFriend.h"

@interface SAFriend ()

@property (copy, nonatomic, readwrite) NSString *friendID;
@property (copy, nonatomic, readwrite) NSString *name;
@property (copy, nonatomic, readwrite) NSString *profileImageURL;

@end

@implementation SAFriend

- (instancetype)init
{
    @throw [NSException exceptionWithName:NSInternalInconsistencyException reason:@"Must use initWithObject: instead." userInfo:nil];
}

- (instancetype)initWithObject:(id)object
{
    self = [super init];
    if (self) {
        self.friendID = (NSString *)[object objectForKey:@"id"];
        self.name = (NSString *)[object objectForKey:@"name"];
        self.profileImageURL = (NSString *)[object objectForKey:@"profile_image_url"];
        self.following = (NSNumber *)[object objectForKey:@"following"];
    }
    return self;
}

@end
