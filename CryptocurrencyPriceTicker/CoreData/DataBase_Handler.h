//
//  DataBase_Handler.h
//  CryptocurrencyPriceTicker
//
//  Created by Rik Tsai on 2018/4/15.
//  Copyright © 2018年 Rik Tsai. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CoreData_Mgr.h"

@interface DataBase_Handler : NSObject

+ (DataBase_Handler*)singleton;
- (void)storeCurrencies:(id)dataSource;
- (void)storeGlobalData:(id)dataSource;
- (void)storeModifyCurrency:(TableCurrency*)currency;
- (NSArray*)fetchCurrenciesByRank:(NSInteger)start andLimit:(NSInteger)limit;
- (TableCurrency*)fetchCurrencyByID:(NSString*)coinID;
- (NSArray*)fetchCurrenciesByFavorite;
- (TableGlobalData*)fetchGlobaData;
- (void)clearWholeCoreData;

@end
