//
//  API_Handler.m
//  CryptocurrencyPriceTicker
//
//  Created by Rik Tsai on 2018/4/14.
//  Copyright © 2018年 Rik Tsai. All rights reserved.
//

#import "API_Handler.h"

@interface API_Handler()
{
    HttpCompletionHandler completionHandler;
    E_API apiType;
}
@end

@implementation API_Handler

- (id)init
{
    self = [super init];
    if (self)
    {
        [Http_Handler singleton];
    }
    
    return self;
}

+ (API_Handler*)singleton
{
    static dispatch_once_t onceToken;
    static API_Handler* instance = nil;
    
    dispatch_once(&onceToken, ^{
        instance = [[API_Handler alloc] init];
    });
    return instance;
}

- (BOOL)isNetworkEnable
{
    NetworkStatus status = [[Http_Handler singleton] currentNetworkStatus];
    if (status == ReachableViaWiFi || status == ReachableViaWWAN)
    {
        return YES;
    }
    else
    {
        return NO;
    }
}

- (void)getTicker:(E_DATA_SOURCE)dataSource
         andStart:(NSInteger)start
         andLimit:(NSInteger)limit
       andConvert:(NSString*)convert
          success:(void (^)(NSArray<TableCurrency*>*))success
          failure:(void (^)(NSInteger))failure
{
    if (dataSource == E_DATABASE)
    {
        // fetch data from database
        NSArray *currencies = [[DataBase_Handler singleton] fetchCurrenciesByRank:start andLimit:limit];
        
        // return data
        success(currencies);
    }
    else  // Cloud
    {
        apiType = E_API_GET_TICKER;
        
        NSMutableDictionary *userInfo = [NSMutableDictionary dictionary];
        [userInfo setValue:[NSNumber numberWithInteger:apiType] forKey:@"apiType"];
        [userInfo setValue:@"GET" forKey:@"method"];
        [userInfo setValue:[NSNumber numberWithInteger:start] forKey:@"start"];
        [userInfo setValue:[NSNumber numberWithInteger:limit] forKey:@"limit"];
        [userInfo setValue:convert forKey:@"convert"];
        
        completionHandler = ^(E_HTTP_RESULT result, id responseDetail)
        {
            NSArray *resultArray = (NSArray*)responseDetail;
            
            if (result == E_HTTP_RESULT_OK)
            {
                // store data
                [[DataBase_Handler singleton] storeCurrencies:resultArray];
                
                // fetch the lastest data
                NSArray *currencies = [[DataBase_Handler singleton] fetchCurrenciesByRank:start andLimit:limit];
                
                // return data
                success(currencies);
            }
            else
            {
                failure((int)result);
            }
        };
        
        [[Http_Handler singleton] sendCloudHttpRequest:completionHandler andJSON:nil andUserInfo:userInfo];
    }
}

- (void)getTickerSpecificCurrency:(E_DATA_SOURCE)dataSource
                        andCoinID:(NSString*)coinID
                       andConvert:(NSString*)convert
                          success:(void (^)(TableCurrency*))success
                          failure:(void (^)(NSInteger))failure
{
    if (dataSource == E_DATABASE)
    {
        // fetch data from database
        TableCurrency *currency = [[DataBase_Handler singleton] fetchCurrencyByID:coinID];
        
        // return data
        success(currency);
    }
    else  // Cloud
    {
        apiType = E_API_GET_TICKER_SPECIFIC;
        
        NSMutableDictionary *userInfo = [NSMutableDictionary dictionary];
        [userInfo setValue:[NSNumber numberWithInteger:apiType] forKey:@"apiType"];
        [userInfo setValue:@"GET" forKey:@"method"];
        [userInfo setValue:coinID forKey:@"coinID"];
        [userInfo setValue:convert forKey:@"convert"];
        
        completionHandler = ^(E_HTTP_RESULT result, id responseDetail)
        {
            NSDictionary *resultArray = (NSDictionary*)responseDetail;
            
            if (result == E_HTTP_RESULT_OK)
            {
                // store data
                [[DataBase_Handler singleton] storeCurrencies:resultArray];
                
                // fetch the lastest data
                TableCurrency *currency = [[DataBase_Handler singleton] fetchCurrencyByID:coinID];
                
                // return data
                success(currency);
            }
            else
            {
                failure((int)result);
            }
        };
        
        [[Http_Handler singleton] sendCloudHttpRequest:completionHandler andJSON:nil andUserInfo:userInfo];
    }
}

- (void)getGlobalData:(E_DATA_SOURCE)dataSource
           andConvert:(NSString*)convert
              success:(void (^)(TableGlobalData*))success
              failure:(void (^)(NSInteger))failure
{
    if (dataSource == E_DATABASE)
    {
        // fetch data from database
        TableGlobalData *global = [[DataBase_Handler singleton] fetchGlobaData];
        
        // return data
        success(global);
    }
    else  // Cloud
    {
        apiType = E_API_GET_GLOBAL_DATA;
        
        NSMutableDictionary *userInfo = [NSMutableDictionary dictionary];
        [userInfo setValue:[NSNumber numberWithInteger:apiType] forKey:@"apiType"];
        [userInfo setValue:@"GET" forKey:@"method"];
        [userInfo setValue:convert forKey:@"convert"];
        
        completionHandler = ^(E_HTTP_RESULT result, id responseDetail)
        {
            NSDictionary *resultsDictionary = (NSDictionary*)responseDetail;
            
            if (result == E_HTTP_RESULT_OK)
            {
                // store data
                [[DataBase_Handler singleton] storeGlobalData:resultsDictionary];
                
                // fetch the lastest data
                TableGlobalData *global = [[DataBase_Handler singleton] fetchGlobaData];
                
                // return data
                success(global);
            }
            else
            {
                failure((int)result);
            }
        };
        
        [[Http_Handler singleton] sendCloudHttpRequest:completionHandler andJSON:nil andUserInfo:userInfo];
    }
}

@end
