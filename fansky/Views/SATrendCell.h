//
//  SATrendCell.h
//  fansky
//
//  Created by Zzy on 16/4/16.
//  Copyright © 2016年 Zzy. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, SATrendCellType) {
    SATrendCellTypeHot = 1,
    SATrendCellTypeRandom = 2
};

@class SATrend;

@interface SATrendCell : UITableViewCell

- (void)configWithTrend:(SATrend *)trend type:(SATrendCellType)type;

@end
