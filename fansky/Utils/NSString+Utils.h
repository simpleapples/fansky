//
//  NSString+Utils.h
//  fansky
//
//  Created by Zzy on 8/24/15.
//  Copyright (c) 2015 Kaoputou. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (Utils)

- (NSDate *)dateWithDefaultFormat;
- (NSDate *)dateWithFormat:(NSString *)format;

@end
