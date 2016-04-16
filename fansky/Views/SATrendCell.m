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

- (void)configWithTrend:(SATrend *)trend
{
    self.titleLabel.text = trend.name;
}

@end
