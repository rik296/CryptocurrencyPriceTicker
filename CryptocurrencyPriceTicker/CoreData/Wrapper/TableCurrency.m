//
//  TableCurrency.m
//  CryptocurrencyPriceTicker
//
//  Created by Rik Tsai on 2018/4/15.
//  Copyright © 2018年 Rik Tsai. All rights reserved.
//

#import "TableCurrency.h"

@implementation TableCurrency

+(void)assignValueToManagedObject:(Currency*)table andItem:(TableCurrency*)item
{
    table.coinID = item.coinID;
    table.name = item.name;
    table.symbol = item.symbol;
    table.rank = item.rank;
    table.price_usd = item.price_usd;
    table.price_btc = item.price_btc;
    table.s24h_volume_usd = item.s24h_volume_usd;
    table.market_cap_usd = item.market_cap_usd;
    table.available_supply = item.available_supply;
    table.total_supply = item.total_supply;
    table.max_supply = item.max_supply;
    table.percent_change_1h = item.percent_change_1h;
    table.percent_change_24h = item.percent_change_24h;
    table.percent_change_7d = item.percent_change_7d;
    table.last_updated = item.last_updated;
    table.fiat_convert = item.fiat_convert;
    table.favorite = item.favorite;
}

+(TableCurrency*)wrapper:(Currency*)item
{
    TableCurrency *table = [[TableCurrency alloc] init];
    table.coinID = item.coinID;
    table.name = item.name;
    table.symbol = item.symbol;
    table.rank = item.rank;
    table.price_usd = item.price_usd;
    table.price_btc = item.price_btc;
    table.s24h_volume_usd = item.s24h_volume_usd;
    table.market_cap_usd = item.market_cap_usd;
    table.available_supply = item.available_supply;
    table.total_supply = item.total_supply;
    table.max_supply = item.max_supply;
    table.percent_change_1h = item.percent_change_1h;
    table.percent_change_24h = item.percent_change_24h;
    table.percent_change_7d = item.percent_change_7d;
    table.last_updated = item.last_updated;
    table.fiat_convert = item.fiat_convert;
    table.favorite = item.favorite;
    
    return table;
}

@end
