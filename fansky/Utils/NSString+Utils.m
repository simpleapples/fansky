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
    return [self dateWithFormat:@"E MMM dd HH:mm:ss Z yyyy"];
}

- (NSDate *)dateWithFormat:(NSString *)format
{
    NSDateFormatter *dateFormatter =[[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = format;
    dateFormatter.locale = [NSLocale localeWithLocaleIdentifier:@"GMT"];
    NSDate *date =[dateFormatter dateFromString:self];
    return date;
}

- (NSString *)flattenHTML
{
    NSScanner *theScanner;
    NSString *text;
    NSString *result = [self copy];
    theScanner = [NSScanner scannerWithString:self];
    while ([theScanner isAtEnd] == NO) {
        [theScanner scanUpToString:@"<" intoString:NULL] ;
        [theScanner scanUpToString:@">" intoString:&text] ;
        result = [result stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"%@>", text] withString:@""];
    }
    return result;
}

@end
