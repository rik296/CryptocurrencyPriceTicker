//
//  DataBase_Handler.m
//  CryptocurrencyPriceTicker
//
//  Created by Rik Tsai on 2018/4/15.
//  Copyright © 2018年 Rik Tsai. All rights reserved.
//

#import "DataBase_Handler.h"

@interface DataBase_Handler()

@end

@implementation DataBase_Handler

- (id)init
{
    self = [super init];
    if (self)
    {
        [CoreData_Mgr singleton];
    }
    
    return self;
}

+ (DataBase_Handler*)singleton
{
    static dispatch_once_t onceToken;
    static DataBase_Handler* instance = nil;
    
    dispatch_once(&onceToken, ^{
        instance = [[DataBase_Handler alloc] init];
    });
    return instance;
}

#pragma mark -
#pragma mark Store Controller

- (void)storeCurrencies:(id)dataSource
{
    if ([dataSource isKindOfClass:[NSArray class]])
    {
        NSArray *returnData = (NSArray*)dataSource;
        for (NSDictionary *item in returnData)
        {
            TableCurrency *currency = [[TableCurrency alloc] init];
            currency.coinID = [item objectForKey:@"id"];
            currency.name = [item objectForKey:@"name"];
            currency.symbol = [item objectForKey:@"symbol"];
            currency.rank = [NSNumber numberWithInteger:[[item objectForKey:@"rank"] integerValue]];
            currency.price_usd = [self checkIsValidData:@"price_usd" andData:item] ? [item objectForKey:@"price_usd"] : @"";
            currency.price_btc = [self checkIsValidData:@"price_btc" andData:item] ? [item objectForKey:@"price_btc"] : @"";
            currency.s24h_volume_usd = [self checkIsValidData:@"24h_volume_usd" andData:item] ? [item objectForKey:@"24h_volume_usd"] : @"";
            currency.market_cap_usd = [self checkIsValidData:@"market_cap_usd" andData:item] ? [item objectForKey:@"market_cap_usd"] : @"";
            currency.available_supply = [self checkIsValidData:@"available_supply" andData:item] ? [item objectForKey:@"available_supply"] : @"";
            currency.total_supply = [self checkIsValidData:@"total_supply" andData:item] ? [item objectForKey:@"total_supply"] : @"";
            currency.max_supply = [self checkIsValidData:@"max_supply" andData:item] ? [item objectForKey:@"max_supply"] : @"";
            currency.percent_change_1h = [self checkIsValidData:@"percent_change_1h" andData:item] ? [item objectForKey:@"percent_change_1h"] : @"";
            currency.percent_change_24h = [self checkIsValidData:@"percent_change_24h" andData:item] ? [item objectForKey:@"percent_change_24h"] : @"";
            currency.percent_change_7d = [self checkIsValidData:@"percent_change_7d" andData:item] ? [item objectForKey:@"percent_change_7d"] : @"";
            currency.last_updated = [self checkIsValidData:@"last_updated" andData:item] ? [item objectForKey:@"last_updated"] : @"";
            
            if ([self isTheSameObject:currency])
            {
                TableCurrency *theSameCurrency = [self fetchCurrencyByID:currency.coinID];
                currency.favorite = theSameCurrency.favorite;
                [[CoreData_Mgr singleton] modifyObject:currency];
            }
            else
            {
                currency.favorite = @(NO);
                [[CoreData_Mgr singleton] addObject:currency];
            }
        }
    }
}

- (void)storeModifyCurrency:(TableCurrency*)currency
{
    [[CoreData_Mgr singleton] modifyObject:currency];
}

- (void)storeGlobalData:(id)dataSource
{
    if ([dataSource isKindOfClass:[NSDictionary class]])
    {
        NSDictionary *returnData = (NSDictionary*)dataSource;
        TableGlobalData *global = [[TableGlobalData alloc] init];
        global.total_market_cap_usd = [returnData objectForKey:@"total_market_cap_usd"];
        global.total_24h_volume_usd = [returnData objectForKey:@"total_24h_volume_usd"];
        global.bitcoin_percentage_of_market_cap = [returnData objectForKey:@"bitcoin_percentage_of_market_cap"];
        global.active_currencies = [returnData objectForKey:@"active_currencies"];
        global.active_assets = [returnData objectForKey:@"active_assets"];
        global.active_markets = [returnData objectForKey:@"active_markets"];
        global.last_updated = [returnData objectForKey:@"last_updated"];
        
        if ([self isTheSameObject:global])
        {
            [[CoreData_Mgr singleton] modifyObject:global];
        }
        else
        {
            [[CoreData_Mgr singleton] addObject:global];
        }
    }
}

- (BOOL)isTheSameObject:(id)object
{
    NSArray *itemArray = nil;
    
    if ([object isKindOfClass:[TableCurrency class]])
    {
        TableCurrency *item = (TableCurrency*)object;
        itemArray = [[CoreData_Mgr singleton].managedObjectContext fetchObjectsForEntityName:@"Currency" predicateWithFormat:@"coinID = %@", item.coinID];
    }
    else if ([object isKindOfClass:[TableGlobalData class]])
    {
        itemArray = [[CoreData_Mgr singleton].managedObjectContext fetchObjectsForEntityName:@"GlobalData"];
    }
    
    if ([itemArray count] > 0)
    {
        return YES;
    }
    else
    {
        return NO;
    }
}

- (BOOL)checkIsValidData:(NSString*)key andData:(id)data
{
    if ([data objectForKey:key] != nil && ![[data objectForKey:key] isKindOfClass:[NSNull class]])
    {
        return YES;
    }
    else
    {
        return NO;
    }
}

#pragma mark -
#pragma mark Fetch Controller

- (NSArray*)fetchCurrenciesByRank:(NSInteger)start andLimit:(NSInteger)limit
{
    int rankStart = (int)(start+1);
    int rankEnd = (int)(start+limit);
    
    NSArray *itemArray = [[CoreData_Mgr singleton].managedObjectContext fetchObjectsForEntityName:@"Currency" predicateWithFormat:@"rank >= %d and rank <= %d", rankStart, rankEnd];
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"rank" ascending:YES];
    NSMutableArray *sortArray = [[NSMutableArray alloc] init];
    [sortArray addObjectsFromArray:[itemArray sortedArrayUsingDescriptors:@[sortDescriptor]]];
    
    NSMutableArray *returnArray = [[NSMutableArray alloc] init];
    
    for (Currency *item in sortArray)
    {
        [returnArray addObject:[TableCurrency wrapper:item]];
    }
    
    return returnArray;
}

- (TableCurrency*)fetchCurrencyByID:(NSString*)coinID
{
    NSArray *itemArray = [[CoreData_Mgr singleton].managedObjectContext fetchObjectsForEntityName:@"Currency" predicateWithFormat:@"coinID = %@", coinID];
    Currency *item = [itemArray objectAtIndex:0];
    TableCurrency *currency = [TableCurrency wrapper:item];
    
    return currency;
}

- (NSArray*)fetchCurrenciesByFavorite
{
    NSArray *itemArray = [[CoreData_Mgr singleton].managedObjectContext fetchObjectsForEntityName:@"Currency" predicateWithFormat:@"favorite = 1"];
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"rank" ascending:YES];
    NSMutableArray *sortArray = [[NSMutableArray alloc] init];
    [sortArray addObjectsFromArray:[itemArray sortedArrayUsingDescriptors:@[sortDescriptor]]];
    
    NSMutableArray *returnArray = [[NSMutableArray alloc] init];
    
    for (Currency *item in sortArray)
    {
        [returnArray addObject:[TableCurrency wrapper:item]];
    }
    
    return returnArray;
}

- (TableGlobalData*)fetchGlobaData
{
    NSArray *itemArray = [[CoreData_Mgr singleton].managedObjectContext fetchObjectsForEntityName:@"GlobalData"];
    GlobalData *global = [itemArray objectAtIndex:0];
    TableGlobalData *retData = [TableGlobalData wrapper:global];
    return retData;
}

#pragma mark -
#pragma mark Delete Controller

- (void)clearWholeCoreData
{
    [[CoreData_Mgr singleton] clearWholeCoreData];
}

@end
