//
//  CurrencyCell.m
//  CryptocurrencyPriceTicker
//
//  Created by Rik Tsai on 2018/4/16.
//  Copyright © 2018年 Rik Tsai. All rights reserved.
//

#import "CurrencyCell.h"

@implementation CurrencyCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    self.percentView.layer.masksToBounds = YES;
    self.percentView.layer.cornerRadius = 8.0;
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
