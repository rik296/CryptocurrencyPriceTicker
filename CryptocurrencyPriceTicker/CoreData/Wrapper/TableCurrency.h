//
//  TableCurrency.h
//  CryptocurrencyPriceTicker
//
//  Created by Rik Tsai on 2018/4/15.
//  Copyright © 2018年 Rik Tsai. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Currency.h"

@interface TableCurrency : NSObject

@property (nonatomic, strong) NSString* coinID;
@property (nonatomic, strong) NSString* name;
@property (nonatomic, strong) NSString* symbol;
@property (nonatomic, strong) NSNumber* rank;
@property (nonatomic, strong) NSString* price_usd;
@property (nonatomic, strong) NSString* price_btc;
@property (nonatomic, strong) NSString* s24h_volume_usd;
@property (nonatomic, strong) NSString* market_cap_usd;
@property (nonatomic, strong) NSString* available_supply;
@property (nonatomic, strong) NSString* total_supply;
@property (nonatomic, strong) NSString* max_supply;
@property (nonatomic, strong) NSString* percent_change_1h;
@property (nonatomic, strong) NSString* percent_change_24h;
@property (nonatomic, strong) NSString* percent_change_7d;
@property (nonatomic, strong) NSString* last_updated;
@property (nonatomic, strong) id fiat_convert;
@property (nonatomic, strong) NSNumber* favorite;

+(void)assignValueToManagedObject:(Currency*)table andItem:(TableCurrency*)item;
+(TableCurrency*)wrapper:(Currency*)item;

@end
