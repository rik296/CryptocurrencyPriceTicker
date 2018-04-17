//
//  GlobalData.h
//  CryptocurrencyPriceTicker
//
//  Created by Rik Tsai on 2018/4/14.
//  Copyright © 2018年 Rik Tsai. All rights reserved.
//

#import <CoreData/CoreData.h>

@interface GlobalData : NSManagedObject

@property (nonatomic, strong) NSNumber* total_market_cap_usd;
@property (nonatomic, strong) NSNumber* total_24h_volume_usd;
@property (nonatomic, strong) NSNumber* bitcoin_percentage_of_market_cap;
@property (nonatomic, strong) NSNumber* active_currencies;
@property (nonatomic, strong) NSNumber* active_assets;
@property (nonatomic, strong) NSNumber* active_markets;
@property (nonatomic, strong) NSNumber* last_updated;
@property (nonatomic, strong) id fiat_convert;

@end
