//
//  TableGlobalData.m
//  CryptocurrencyPriceTicker
//
//  Created by Rik Tsai on 2018/4/15.
//  Copyright © 2018年 Rik Tsai. All rights reserved.
//

#import "TableGlobalData.h"

@implementation TableGlobalData

+(void)assignValueToManagedObject:(GlobalData*)table andItem:(TableGlobalData*)item
{
    table.total_market_cap_usd = item.total_market_cap_usd;
    table.total_24h_volume_usd = item.total_24h_volume_usd;
    table.bitcoin_percentage_of_market_cap = item.bitcoin_percentage_of_market_cap;
    table.active_currencies = item.active_currencies;
    table.active_assets = item.active_assets;
    table.active_markets = item.active_markets;
    table.last_updated = item.last_updated;
    table.fiat_convert = item.fiat_convert;
}

+(TableGlobalData*)wrapper:(GlobalData*)item
{
    TableGlobalData *table = [[TableGlobalData alloc] init];
    table.total_market_cap_usd = item.total_market_cap_usd;
    table.total_24h_volume_usd = item.total_24h_volume_usd;
    table.bitcoin_percentage_of_market_cap = item.bitcoin_percentage_of_market_cap;
    table.active_currencies = item.active_currencies;
    table.active_assets = item.active_assets;
    table.active_markets = item.active_markets;
    table.last_updated = item.last_updated;
    table.fiat_convert = item.fiat_convert;
    
    return table;
}

@end
