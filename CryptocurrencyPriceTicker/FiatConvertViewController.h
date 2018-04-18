//
//  FiatConvertViewController.h
//  CryptocurrencyPriceTicker
//
//  Created by Rik Tsai on 2018/4/18.
//  Copyright © 2018年 Rik Tsai. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FiatConvertViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) NSString *coinID;

@end
