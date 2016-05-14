//
//  SATrendCell.m
//  fansky
//
//  Created by Zzy on 16/4/16.
//  Copyright © 2016年 Zzy. All rights reserved.
//

#import "SATrendCell.h"
#import "SATrend.h"

@interface SATrendCell ()

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *detailLabel;

@end

@implementation SATrendCell

- (void)awakeFromNib
{
    [super awakeFromNib];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
}

- (void)configWithTrend:(SATrend *)trend type:(SATrendCellType)type
{
    if (type == SATrendCellTypeHot && trend) {
        self.titleLabel.text = trend.name;
        self.detailLabel.text = trend.query;
    } else if (type == SATrendCellTypeRandom) {
        self.titleLabel.text = @"随便看看";
        self.detailLabel.text = @"";
    }
}

@end
