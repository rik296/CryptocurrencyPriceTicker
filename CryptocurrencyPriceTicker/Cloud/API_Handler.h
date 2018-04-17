//
//  API_Handler.h
//  CryptocurrencyPriceTicker
//
//  Created by Rik Tsai on 2018/4/14.
//  Copyright © 2018年 Rik Tsai. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Http_Handler.h"
#import "DataBase_Handler.h"

typedef NS_ENUM(NSUInteger, E_DATA_SOURCE)
{
    E_CLOUD = 0,
    E_DATABASE
};

@interface API_Handler : NSObject

+ (API_Handler*)singleton;

- (void)getTicker:(E_DATA_SOURCE)dataSource
         andStart:(NSInteger)start
         andLimit:(NSInteger)limit
       andConvert:(NSString*)convert
          success:(void (^)(NSArray<TableCurrency*>* currencies))success
          failure:(void (^)(NSInteger retCode))failure;

- (void)getTickerSpecificCurrency:(E_DATA_SOURCE)dataSource
                        andCoinID:(NSString*)coinID
                       andConvert:(NSString*)convert
                          success:(void (^)(TableCurrency* currency))success
                          failure:(void (^)(NSInteger retCode))failure;

- (void)getGlobalData:(E_DATA_SOURCE)dataSource
           andConvert:(NSString*)convert
              success:(void (^)(TableGlobalData* global))success
              failure:(void (^)(NSInteger retCode))failure;

@end
