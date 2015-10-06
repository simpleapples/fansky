//
//  SAFriend.h
//  fansky
//
//  Created by Zzy on 10/7/15.
//  Copyright © 2015 Zzy. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SAFriend : NSObject

@property (copy, nonatomic, readonly) NSString *friendID;
@property (copy, nonatomic, readonly) NSString *name;
@property (copy, nonatomic, readonly) NSString *profileImageURL;

- (instancetype)initWithObject:(id)object;

@end
