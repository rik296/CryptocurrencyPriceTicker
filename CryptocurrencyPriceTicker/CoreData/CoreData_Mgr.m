//
//  CoreData_Mgr.m
//  CryptocurrencyPriceTicker
//
//  Created by Rik Tsai on 2018/4/15.
//  Copyright © 2018年 Rik Tsai. All rights reserved.
//

#import "CoreData_Mgr.h"

@implementation CoreData_Mgr

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

+ (CoreData_Mgr*)singleton
{
    static dispatch_once_t onceToken;
    static CoreData_Mgr* instance = nil;
    
    dispatch_once(&onceToken, ^{
        instance = [[CoreData_Mgr alloc] init];
    });
    return instance;
}

- (void)addObject:(id)object
{
    if ([object isKindOfClass:[TableCurrency class]])
    {
        TableCurrency *item = (TableCurrency*)object;
        Currency *table = [NSEntityDescription insertNewObjectForEntityForName:@"Currency" inManagedObjectContext:self.managedObjectContext];
        [TableCurrency assignValueToManagedObject:table andItem:item];
    }
    else if ([object isKindOfClass:[TableGlobalData class]])
    {
        TableGlobalData *item = (TableGlobalData*)object;
        GlobalData *table = [NSEntityDescription insertNewObjectForEntityForName:@"GlobalData" inManagedObjectContext:self.managedObjectContext];
        [TableGlobalData assignValueToManagedObject:table andItem:item];
    }
    
    NSError *error;
    if (![self.managedObjectContext save:&error]) {
        // Replace this implementation with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
}

- (void)modifyObject:(id)object
{
    if ([object isKindOfClass:[TableCurrency class]])
    {
        TableCurrency *item = (TableCurrency*)object;
        NSArray *tableArray = [self.managedObjectContext fetchObjectsForEntityName:@"Currency" predicateWithFormat:@"coinID = %@", item.coinID];
        if ([tableArray count] > 0)
        {
            Currency *table = [tableArray objectAtIndex:0];
            [TableCurrency assignValueToManagedObject:table andItem:item];
        }
    }
    else if ([object isKindOfClass:[TableGlobalData class]])
    {
        TableGlobalData *item = (TableGlobalData*)object;
        NSArray *tableArray = [self.managedObjectContext fetchObjectsForEntityName:@"GlobalData"];
        if ([tableArray count] > 0)
        {
            GlobalData *table = [tableArray objectAtIndex:0];
            [TableGlobalData assignValueToManagedObject:table andItem:item];
        }
    }
    
    NSError *error;
    if (![self.managedObjectContext save:&error]) {
        // Replace this implementation with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
}

- (void)deleteObject:(id)object
{
    NSArray *tableArray = nil;
    
    if ([object isKindOfClass:[TableCurrency class]])
    {
        TableCurrency *item = (TableCurrency*)object;
        tableArray = [self.managedObjectContext fetchObjectsForEntityName:@"Currency" predicateWithFormat:@"coinID = %@", item.coinID];
    }
    else if ([object isKindOfClass:[TableGlobalData class]])
    {
        //TableGlobalData *item = (TableGlobalData*)object;
        tableArray = [self.managedObjectContext fetchObjectsForEntityName:@"GlobalData"];
    }
    
    if ([tableArray count] > 0)
    {
        [self.managedObjectContext deleteObject:[tableArray objectAtIndex:0]];
    }
    
    NSError *error;
    if (![self.managedObjectContext save:&error]) {
        // Replace this implementation with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
}

- (void)clearWholeCoreData
{
    NSArray *currencyArray = [self.managedObjectContext fetchObjectsForEntityName:@"Currency"];
    for(Currency *item in currencyArray)
    {
        [self.managedObjectContext deleteObject:item];
    }
    
    NSArray *globalArray = [self.managedObjectContext fetchObjectsForEntityName:@"GlobalData"];
    for(GlobalData *item in globalArray)
    {
        [self.managedObjectContext deleteObject:item];
    }
    
    NSError *error;
    if (![self.managedObjectContext save:&error]) {
        // Replace this implementation with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
}

#pragma mark -
#pragma mark Core Data stack

// Returns the managed object context for the application.
// If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
- (NSManagedObjectContext *)managedObjectContext
{
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        _managedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
        [_managedObjectContext setPersistentStoreCoordinator:coordinator];
        [_managedObjectContext setMergePolicy:NSMergeByPropertyObjectTrumpMergePolicy];
    }
    return _managedObjectContext;
}

// Returns the managed object model for the application.
// If the model doesn't already exist, it is created from the application's model.
- (NSManagedObjectModel *)managedObjectModel
{
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"Model" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

// Returns the persistent store coordinator for the application.
// If the coordinator doesn't already exist, it is created and the application's store added to it.
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    NSString *storePath = [[self applicationPrivateDocumentsDirectory] stringByAppendingPathComponent:@"Model.sqlite"];
    
    NSError *error = nil;
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    //Check to see what version of the current model we're in. If it's >= 2.0, then and ONLY then check if migration has been performed...
    NSSet *versionIdentifiers = [[self managedObjectModel] versionIdentifiers];
    NSLog(@"Which Current Version is our .xcdatamodeld file set to? %@", versionIdentifiers);
    
    if ([versionIdentifiers containsObject:@"2.0"])
    {
        BOOL hasMigrated = [self checkForMigration];
        
        if (hasMigrated==YES) {
            storePath = [[self applicationPrivateDocumentsDirectory] stringByAppendingPathComponent:@"Model_V2.sqlite"];
        }
    }
    
    NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:
                             [NSNumber numberWithBool:YES], NSMigratePersistentStoresAutomaticallyOption,
                             [NSNumber numberWithBool:NO], NSInferMappingModelAutomaticallyOption, nil];
    
    NSURL *storeURL = [NSURL fileURLWithPath:storePath];
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:options error:&error]) {
        /*
         Replace this implementation with code to handle the error appropriately.
         
         abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
         
         Typical reasons for an error here include:
         * The persistent store is not accessible;
         * The schema for the persistent store is incompatible with current managed object model.
         Check the error message to determine what the actual problem was.
         
         
         If the persistent store is not accessible, there is typically something wrong with the file path. Often, a file URL is pointing into the application's resources directory instead of a writeable directory.
         
         If you encounter schema incompatibility errors during development, you can reduce their frequency by:
         * Simply deleting the existing store:
         [[NSFileManager defaultManager] removeItemAtURL:storeURL error:nil]
         
         * Performing automatic lightweight migration by passing the following dictionary as the options parameter:
         @{NSMigratePersistentStoresAutomaticallyOption:@YES, NSInferMappingModelAutomaticallyOption:@YES}
         
         Lightweight migration will only work for a limited set of schema changes; consult "Core Data Model Versioning and Data Migration Programming Guide" for details.
         
         */
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    return _persistentStoreCoordinator;
}

//This won't even get called unless our versionIdentifiers has confirmed that our Version 2 model exists.
- (BOOL)checkForMigration
{
    BOOL migrationSuccess = NO;
    NSString *storeSourcePath = [[self applicationPrivateDocumentsDirectory] stringByAppendingPathComponent:@"GOLiFE_Fit_V2.sqlite"];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    if (![fileManager fileExistsAtPath:storeSourcePath])
    {
        //Version 2 SQL has not been created yet, so the source is still version 1...
        storeSourcePath = [[self applicationPrivateDocumentsDirectory] stringByAppendingPathComponent:@"GOLiFE_Fit.sqlite"];
    }
    
    NSURL *storeSourceUrl = [NSURL fileURLWithPath: storeSourcePath];
    NSError *error = nil;
    NSDictionary *sourceMetadata = [NSPersistentStoreCoordinator metadataForPersistentStoreOfType:NSSQLiteStoreType
                                                                                              URL:storeSourceUrl
                                                                                          options:nil
                                                                                            error:&error];
    if (sourceMetadata)
    {
        NSString *configuration = nil;
        NSManagedObjectModel *destinationModel = [self.persistentStoreCoordinator managedObjectModel];
        
        //Our Source 1 is going to be incompatible with the Version 2 Model, our Source 2 won't be...
        BOOL pscCompatible = [destinationModel isConfiguration:configuration compatibleWithStoreMetadata:sourceMetadata];
        NSLog(@"Is the STORE data COMPATIBLE? %@", (pscCompatible==YES) ? @"YES" : @"NO");
        
        if (pscCompatible == NO) {
            migrationSuccess = [self performMigrationWithSourceMetadata:sourceMetadata toDestinationModel:destinationModel];
        }
    }
    else {
        NSLog(@"checkForMigration FAIL - No Source Metadata! \nERROR: %@", [error localizedDescription]);
    }
    return migrationSuccess;
}//END

- (BOOL)performMigrationWithSourceMetadata :(NSDictionary *)sourceMetadata toDestinationModel:(NSManagedObjectModel *)destinationModel
{
    BOOL migrationSuccess = NO;
    //Initialise a Migration Manager...
    NSManagedObjectModel *sourceModel = [NSManagedObjectModel mergedModelFromBundles:nil
                                                                    forStoreMetadata:sourceMetadata];
    //Perform the migration...
    if (sourceModel) {
        NSMigrationManager *standardMigrationManager = [[NSMigrationManager alloc] initWithSourceModel:sourceModel
                                                                                      destinationModel:destinationModel];
        //Retrieve the appropriate mapping model...
        NSMappingModel *mappingModel = [NSMappingModel mappingModelFromBundles:nil
                                                                forSourceModel:sourceModel
                                                              destinationModel:destinationModel];
        if (mappingModel)
        {
            NSError *error = nil;
            
            NSString *sourcePathV1 = [[self applicationPrivateDocumentsDirectory] stringByAppendingPathComponent:@"Model.sqlite"];
            NSURL *storeSourceUrl ;
            
            NSString *storeDestPath = [[self applicationPrivateDocumentsDirectory] stringByAppendingPathComponent:@" Model_V2.sqlite"];
            NSURL *storeDestUrl = [NSURL fileURLWithPath:storeDestPath];
            
            // for check the version
            storeSourceUrl = [NSURL fileURLWithPath:sourcePathV1];
            
            //Pass nil here because we don't want to use any of these options:
            //NSIgnorePersistentStoreVersioningOption, NSMigratePersistentStoresAutomaticallyOption, or NSInferMappingModelAutomaticallyOption
            NSDictionary *sourceStoreOptions = nil;
            NSDictionary *destinationStoreOptions = nil;
            
            migrationSuccess = [standardMigrationManager migrateStoreFromURL:storeSourceUrl
                                                                        type:NSSQLiteStoreType
                                                                     options:sourceStoreOptions
                                                            withMappingModel:mappingModel
                                                            toDestinationURL:storeDestUrl
                                                             destinationType:NSSQLiteStoreType
                                                          destinationOptions:destinationStoreOptions
                                                                       error:&error];
            
            NSLog(@"MIGRATION SUCCESSFUL? %@", (migrationSuccess==YES) ? @"YES" : @"NO");
        }
    }
    else {
        //TODO: Error to user...
        NSLog(@"checkForMigration FAIL - No Mapping Model found!");
        abort();
    }
    return migrationSuccess;
}//END

#pragma mark - 
#pragma mark Application's Documents directory

// Returns the URL to the application's Documents directory.
- (NSString *)applicationDocumentsDirectory
{
    return [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
}

- (NSString *)applicationPrivateDocumentsDirectory
{
    static NSString *path;
    if (!path) {
        NSString *libraryPath = [NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) lastObject];
        path = [libraryPath stringByAppendingPathComponent:@"Private Documents"];
        BOOL isDirectory;
        if (![[NSFileManager defaultManager] fileExistsAtPath:path isDirectory:&isDirectory]) {
            NSError *error = nil;
            if (![[NSFileManager defaultManager] createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:&error]) {
                NSLog(@"Can't create directory %@ [%@]", path, error);
                abort(); // replace with proper error handling
            }
        }
        else if (!isDirectory) {
            NSLog(@"Path %@ exists but is no directory", path);
            abort(); // replace with error handling
        }
    }
    return path;
}

@end
