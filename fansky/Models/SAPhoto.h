//
//  SAPhoto.h
//  fansky
//
//  Created by Zzy on 16/3/21.
//  Copyright © 2016年 Zzy. All rights reserved.
//

#import <Realm/Realm.h>

@interface SAPhoto : RLMObject

@property NSString *imageURL;
@property NSString *thumbURL;
@property NSString *largeURL;
@property NSString *photoURL;

@end
