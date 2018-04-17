//
//  CurrencyCell.h
//  CryptocurrencyPriceTicker
//
//  Created by Rik Tsai on 2018/4/16.
//  Copyright © 2018年 Rik Tsai. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CurrencyCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *icon;
@property (weak, nonatomic) IBOutlet UILabel *symbol;
@property (weak, nonatomic) IBOutlet UILabel *rankAndName;
@property (weak, nonatomic) IBOutlet UILabel *value;
@property (weak, nonatomic) IBOutlet UIView *percentView;
@property (weak, nonatomic) IBOutlet UILabel *percent;

@end
