//
//  CoreData_Mgr.h
//  CryptocurrencyPriceTicker
//
//  Created by Rik Tsai on 2018/4/15.
//  Copyright © 2018年 Rik Tsai. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NSManagedObjectContext-EasyFetch.h"
#import "TableCurrency.h"
#import "TableGlobalData.h"

@interface CoreData_Mgr : NSObject

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

+ (CoreData_Mgr*)singleton;

- (void)addObject:(id)object;
- (void)modifyObject:(id)object;
- (void)deleteObject:(id)object;
- (void)clearWholeCoreData;

@end
