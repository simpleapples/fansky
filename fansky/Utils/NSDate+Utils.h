//
//  NSDate+Utils.h
//  fansky
//
//  Created by Zzy on 9/14/15.
//  Copyright (c) 2015 Zzy. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDate (Utils)

- (NSString *)friendlyDateString;
- (NSString *)defaultDateString;
- (NSString *)dateStringWithFormat:(NSString *)format;

@end
