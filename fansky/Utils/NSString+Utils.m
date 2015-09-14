//
//  NSString+Utils.m
//  fansky
//
//  Created by Zzy on 8/24/15.
//  Copyright (c) 2015 Kaoputou. All rights reserved.
//

#import "NSString+Utils.h"

@implementation NSString (Utils)

- (NSDate *)dateWithDefaultFormat
{
    return [self dateWithFormat:@"E, dd MMM yyyy HH:mm:ss Z"];
}

- (NSDate *)dateWithFormat:(NSString *)format
{
    NSDateFormatter *dateFormatter =[[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = format;
    dateFormatter.locale = [NSLocale localeWithLocaleIdentifier:@"GMT"];
    NSDate *date =[dateFormatter dateFromString:self];
    return date;
}

@end
