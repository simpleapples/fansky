//
//  NSDate+Utils.m
//  fansky
//
//  Created by Zzy on 9/14/15.
//  Copyright (c) 2015 Zzy. All rights reserved.
//

#import "NSDate+Utils.h"

@implementation NSDate (Utils)

- (NSString *)friendlyDateString
{
    NSDate *nowDate = [NSDate date];
    NSTimeInterval timeInterval = [nowDate timeIntervalSinceDate:self];
    
    NSInteger days = (NSInteger)(timeInterval / (3600 * 24));
    NSInteger hours = (NSInteger)(timeInterval - days * 3600 * 24) / 3600;
    NSInteger minutes = (NSInteger)(timeInterval - days * 3600 * 24 - hours * 3600) / 60;

    if (days >= 1) {
        return [NSString stringWithFormat:@"%zd天前", days];
    } else if (hours >= 1) {
        return [NSString stringWithFormat:@"%zd小时前", hours];
    } else if (minutes >= 1) {
        return [NSString stringWithFormat:@"%zd分前", minutes];
    }
    return [NSString stringWithFormat:@"刚才"];
}

- (NSString *)defaultDateString
{
    return [self dateStringWithFormat:@"yyyy-MM-dd HH:mm"];
}

- (NSString *)dateStringWithFormat:(NSString *)format
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = format;
    return [dateFormatter stringFromDate:self];
}

@end
