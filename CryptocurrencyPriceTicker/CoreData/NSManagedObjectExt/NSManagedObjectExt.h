
#import <CoreData/CoreData.h>

#if 0
@interface NSManagedObject (safeSetValuesKeysWithDictionary)
- (void)safeSetValuesForKeysWithDictionary:(NSDictionary *)keyedValues dateFormatter:(NSDateFormatter *)dateFormatter;
- (void)safeSetRelationshipForKeysWithDictionary:(NSDictionary *)keyedValues dateFormatter:(NSDateFormatter *)dateFormatter inManagedObjectContext:(NSManagedObjectContext *)context;
- (NSDictionary *)yamlDictionaryWithValuesForKeys:(NSArray *)keys;
@end
#endif

@interface NSDictionary (Helpers)
 
+ (NSDictionary *)dictionaryWithContentsOfData:(NSData *)data;
 
@end

@interface NSManagedObject(MCAggregate)
+ (NSNumber *)aggregateOperation:(NSString *)function onAttribute:(NSString *)attributeName withPredicate:(NSPredicate *)predicate inManagedObjectContext:(NSManagedObjectContext *)context;
@end