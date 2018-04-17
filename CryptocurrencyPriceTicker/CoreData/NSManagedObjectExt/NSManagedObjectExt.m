#import "NSManagedObjectExt.h"
#import "NSManagedObjectContext-EasyFetch.h"

#if 0
#import "PapaGoAppDelegate.h"
#import "GoLifeSyncML.h"

@implementation NSManagedObject (safeSetValuesKeysWithDictionary)

- (void)safeSetValuesForKeysWithDictionary:(NSDictionary *)keyedValues dateFormatter:(NSDateFormatter *)dateFormatter
{
    NSDictionary *attributes = [[self entity] attributesByName];
    for (NSAttributeDescription *eachA in [attributes allValues]) {
        NSString* attribute = [NSString stringWithString:eachA.name];
        //NSLog(@"attribute %@",attribute);
        id value = [keyedValues objectForKey:attribute];
        //Workaround for name conflict
        if ([attribute isEqualToString:@"description_"])
        {
            value = [keyedValues objectForKey:@"description"];
        }
        if (value == nil || ([value isKindOfClass:[NSString class]]&&[value isEqualToString:@"null"])) {
            continue;
        }
        NSAttributeType attributeType = [[attributes objectForKey:attribute] attributeType];

        if ((attributeType == NSStringAttributeType) && ([value isKindOfClass:[NSNumber class]])) {
            value = [value stringValue];
        } else if (((attributeType == NSInteger16AttributeType) || (attributeType == NSInteger32AttributeType) || (attributeType == NSInteger64AttributeType) || (attributeType == NSBooleanAttributeType)) && ([value isKindOfClass:[NSString class]])) {
            value = [NSNumber numberWithInteger:[value integerValue]];
        } else if ((attributeType == NSFloatAttributeType) &&  ([value isKindOfClass:[NSString class]])) {
            value = [NSNumber numberWithDouble:[value doubleValue]];
        } else if ((attributeType == NSDateAttributeType) && ([value isKindOfClass:[NSString class]]) && (dateFormatter != nil)) {
            //NSLog(@"key %@ value %@",attribute,value);
            value = [dateFormatter dateFromString:value];
            //NSLog(@"key %@ value %@",attribute,value);
        }
        else if (attributeType == NSTransformableAttributeType && nil != [eachA valueTransformerName])
        {
            //const char* className = class_getName([self valueForKey:attribute]);
            //NSLog(@"yourObject is a: %s %@", className,value);
            NSValueTransformer *valueTransformer = [NSValueTransformer valueTransformerForName:[eachA valueTransformerName]];
            [self setValue:[valueTransformer reverseTransformedValue:value] forKey:attribute];
            continue;
        }
        else if (((attributeType == NSInteger16AttributeType) || (attributeType == NSInteger32AttributeType) || (attributeType == NSInteger64AttributeType) || (attributeType == NSBooleanAttributeType)) && ([value isKindOfClass:[NSDictionary class]]))
        {
            continue;
        }
        
        //NSLog(@"key %@ value %@",attribute,value);
        [self setValue:value forKey:attribute];
    }
}

- (void)safeSetRelationshipForKeysWithDictionary:(NSDictionary *)keyedValues dateFormatter:(NSDateFormatter *)dateFormatter inManagedObjectContext:(NSManagedObjectContext *)context
{
    NSDictionary *relationships = [[self entity] relationshipsByName];
    //PapaGoAppDelegate  *currentDelegate = [[UIApplication sharedApplication] delegate];
    //NSManagedObjectContext *managedObjectContext = [[currentDelegate m_goLifeSyncML] managedObjectContext];
    NSManagedObjectContext *managedObjectContext = context;
    for (NSRelationshipDescription *eachA in [relationships allValues]) {
        NSString* relationship = [NSString stringWithString:eachA.name];
        //NSLog(@"key %@ value %@",relationship,[keyedValues objectForKey:@"90"]);
        if ([relationship isEqualToString:@"ninezero"])
        {
            NSDictionary *dict = [keyedValues objectForKey:@"90"];
            NSManagedObject *data = [NSEntityDescription insertNewObjectForEntityForName:[[eachA destinationEntity] name] inManagedObjectContext:managedObjectContext];
            [data safeSetValuesForKeysWithDictionary:dict dateFormatter:nil];
            [self setValue:data forKey:relationship];
            //NSLog(@"Create Relationship gid data %@",data);
        }
        else if ([relationship isEqualToString:@"onethreezero"])
        {
            NSDictionary *dict = [keyedValues objectForKey:@"130"];
            NSManagedObject *data = [NSEntityDescription insertNewObjectForEntityForName:[[eachA destinationEntity] name] inManagedObjectContext:managedObjectContext];
            [data safeSetValuesForKeysWithDictionary:dict dateFormatter:nil];
            [self setValue:data forKey:relationship];
            //NSLog(@"Create Relationship gid data %@",data);
        }
        else if ([relationship isEqualToString:@"twofourzero"])
        {
            NSDictionary *dict = [keyedValues objectForKey:@"240"];
            NSManagedObject *data = [NSEntityDescription insertNewObjectForEntityForName:[[eachA destinationEntity] name] inManagedObjectContext:managedObjectContext];
            [data safeSetValuesForKeysWithDictionary:dict dateFormatter:nil];
            [self setValue:data forKey:relationship];
            //NSLog(@"Create Relationship gid data %@",data);
        }
        //NSLog(@"relationship %@",relationship);
        if ([eachA isToMany])
        {
            if ([[keyedValues objectForKey:relationship] isKindOfClass:[NSArray class]])
            {
                NSMutableSet *clonedSet = [self mutableSetValueForKey:relationship];
                [clonedSet removeAllObjects];
                for (NSDictionary * dict in [keyedValues objectForKey:relationship])
                {
                    if (nil != [dict valueForKey:@"id"])
                    {
                        NSArray * datas = [self.managedObjectContext fetchObjectsForEntityName:[[eachA destinationEntity] name] predicateWithFormat:@"id = %@",[dict valueForKey:@"id"]];
                        if ([datas count] > 0)
                        {
                            for (NSManagedObject *data in datas)
                            {
                                [clonedSet addObject:data];
                            }
                        }
                        else
                        {
                            NSManagedObject *data = [NSEntityDescription insertNewObjectForEntityForName:[[eachA destinationEntity] name] inManagedObjectContext:managedObjectContext];
                            [data safeSetValuesForKeysWithDictionary:dict dateFormatter:dateFormatter];
                            [data safeSetRelationshipForKeysWithDictionary:dict dateFormatter:dateFormatter inManagedObjectContext:managedObjectContext];
                            [clonedSet addObject:data];
                        }
                    }
                    else if (nil != [dict valueForKey:@"gid"])
                    {
                        NSArray * datas = [self.managedObjectContext fetchObjectsForEntityName:[[eachA destinationEntity] name] predicateWithFormat:@"gid = %@",[dict valueForKey:@"gid"]];
                        if ([datas count] > 0)
                        {
                            for (NSManagedObject *data in datas)
                            {
                                [clonedSet addObject:data];
                            }
                        }
                        else
                        {
                            NSManagedObject *data = [NSEntityDescription insertNewObjectForEntityForName:[[eachA destinationEntity] name] inManagedObjectContext:managedObjectContext];
                            [data safeSetValuesForKeysWithDictionary:dict dateFormatter:nil];
                            [data safeSetRelationshipForKeysWithDictionary:dict dateFormatter:dateFormatter inManagedObjectContext:managedObjectContext];
                            [clonedSet addObject:data];
                        }
                    }
                    else
                    {
                        NSManagedObject *data = [NSEntityDescription insertNewObjectForEntityForName:[[eachA destinationEntity] name] inManagedObjectContext:managedObjectContext];
                        [data safeSetValuesForKeysWithDictionary:dict dateFormatter:nil];
                        [data safeSetRelationshipForKeysWithDictionary:dict dateFormatter:dateFormatter inManagedObjectContext:managedObjectContext];
                        [clonedSet addObject:data];
                    }
                }
            }
        }
        else
        {
            if (![[keyedValues objectForKey:relationship] isKindOfClass:[NSDictionary class]])
            {
                continue;
            }
            NSDictionary *dict = [keyedValues objectForKey:relationship];
           // NSLog(@"Relationship %@",dict);
            if (nil != [dict valueForKey:@"id"])
            {
                NSArray * datas = [self.managedObjectContext fetchObjectsForEntityName:[[eachA destinationEntity] name] predicateWithFormat:@"id = %@",[dict valueForKey:@"id"]];
                //NSLog(@"Relationship id = %@",[dict valueForKey:@"id"]);
                if ([datas count] > 0)
                {
                    for (NSManagedObject *data in datas)
                    {
                        [self setValue:data forKey:relationship];
                        //NSLog(@"Relationship data %@",[self valueForKey:relationship]);
                    }
                }
                else
                {
                    NSManagedObject *data = [NSEntityDescription insertNewObjectForEntityForName:[[eachA destinationEntity] name] inManagedObjectContext:managedObjectContext];
                    [data safeSetValuesForKeysWithDictionary:dict dateFormatter:nil];
                    [data safeSetRelationshipForKeysWithDictionary:dict dateFormatter:dateFormatter inManagedObjectContext:managedObjectContext];
                    [self setValue:data forKey:relationship];
                    //NSLog(@"Create Relationship gid data %@",data);
                }
            }
            else if (nil != [dict valueForKey:@"gid"])
            {
                NSArray * datas = [self.managedObjectContext fetchObjectsForEntityName:[[eachA destinationEntity] name] predicateWithFormat:@"gid = %@",[dict valueForKey:@"gid"]];
                if ([datas count] > 0)
                {
                    for (NSManagedObject *data in datas)
                    {
                        [self setValue:data forKey:relationship];
                        //NSLog(@"Relationship gid data %@",data);
                    }
                }
                else
                {
                    NSManagedObject *data = [NSEntityDescription insertNewObjectForEntityForName:[[eachA destinationEntity] name] inManagedObjectContext:managedObjectContext];
                    [data safeSetValuesForKeysWithDictionary:dict dateFormatter:nil];
                    [data safeSetRelationshipForKeysWithDictionary:dict dateFormatter:dateFormatter inManagedObjectContext:managedObjectContext];
                    [self setValue:data forKey:relationship];
                }
            }
            else
            {
                NSManagedObject *data = [NSEntityDescription insertNewObjectForEntityForName:[[eachA destinationEntity] name] inManagedObjectContext:managedObjectContext];
                [data safeSetValuesForKeysWithDictionary:dict dateFormatter:nil];
                [data safeSetRelationshipForKeysWithDictionary:dict dateFormatter:dateFormatter inManagedObjectContext:managedObjectContext];
                [self setValue:data forKey:relationship];
            }
            /*
            NSManagedObject *data = [NSEntityDescription insertNewObjectForEntityForName:[[eachA destinationEntity] name] inManagedObjectContext:managedObjectContext];
            [data safeSetValuesForKeysWithDictionary:[keyedValues objectForKey:relationship] dateFormatter:nil];
            [self setValue:data forKey:relationship];
             */
        }
    }
}

- (NSDictionary *)yamlDictionaryWithValuesForKeys:(NSArray *)keys
{
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    for (NSString *keyName in keys)
    {
        if ([keyName isEqualToString:@"ownsPOI"]||[keyName isEqualToString:@"poiData"]||[keyName isEqualToString:@"categoryPois"])
        {
            continue;
        }
        id value = [self valueForKey:keyName];
        if (nil == value)
            continue;
        //Workaround for name conflict
        if ([keyName isEqualToString:@"description_"])
        {
            keyName = @"description";
        }
        else if ([keyName isEqualToString:@"ninezero"])
        {
            keyName = @"90";
        }
        else if ([keyName isEqualToString:@"onethreezero"])
        {
            keyName = @"130";
        }
        else if ([keyName isEqualToString:@"twofourzero"])
        {
            keyName = @"240";
        }
        //NSLog(@"Relationship gid data %@",keyName);
        if ([value isKindOfClass:[NSString class]])
        {
            [dict setObject:value forKey:keyName];
        }
        else if ([value isKindOfClass:[NSManagedObject class]])
        {
            NSArray *entryKeys = [[[value entity] propertiesByName] allKeys];
            NSDictionary *entryDict = [value yamlDictionaryWithValuesForKeys:entryKeys];
            [dict setObject:entryDict forKey:keyName];
            [entryDict release];
        }
        else if ([value isKindOfClass:[NSSet class]])
        {
            NSMutableArray *dataArray = [[NSMutableArray alloc] init];
            for (id dataValue in value)
            {
                NSArray *entryKeys = [[[dataValue entity] propertiesByName] allKeys];
                NSMutableDictionary *entryDict = [[NSMutableDictionary alloc] initWithDictionary:[dataValue yamlDictionaryWithValuesForKeys:entryKeys]];
                //NSLog(@"yamlDictionaryWithValuesForKeys %@",entryDict);
                if (nil != [entryDict valueForKey:@"statusUpload"] && 1 == [[entryDict valueForKey:@"statusUpload"] integerValue])
                {
                    [entryDict release];
                    continue;
                }
                else
                {
                    if (nil != [entryDict valueForKey:@"statusUpload"])
                    {
                        [entryDict removeObjectForKey:@"statusUpload"];
                    }
                }
                [dataArray addObject:entryDict];
                [entryDict release];
            }
            [dict setObject:dataArray forKey:keyName];
            [dataArray release];
        }
        else
        {
            [dict setObject:value forKey:keyName];
        }
    }
    //NSDictionary *result = dict;
    //[dict release];
    return dict;
}
@end
#endif

@implementation NSDictionary (Helpers)

+ (NSDictionary *)dictionaryWithContentsOfData:(NSData *)data
{
	// uses toll-free bridging for data into CFDataRef and CFPropertyList into NSDictionary
	//CFPropertyListRef plist =  CFPropertyListCreateFromXMLData(kCFAllocatorDefault, (CFDataRef)data,
	//														   kCFPropertyListImmutable,
	//														   NULL);
    
    CFPropertyListRef plist =  CFPropertyListCreateWithData(kCFAllocatorDefault, (CFDataRef)data, kCFPropertyListImmutable, NULL, NULL);
    
	// we check if it is the correct type and only return it if it is
	if ([(id)plist isKindOfClass:[NSDictionary class]])
	{
		return [(NSDictionary *)plist autorelease];
	}
	else
	{
		// clean up ref
		CFRelease(plist);
		return nil;
	}
}

@end

@implementation NSManagedObject(MCAggregate)
+(NSNumber *)aggregateOperation:(NSString *)function onAttribute:(NSString *)attributeName withPredicate:(NSPredicate *)predicate inManagedObjectContext:(NSManagedObjectContext *)context
{
    NSExpression *ex = [NSExpression expressionForFunction:function
                                                 arguments:[NSArray arrayWithObject:[NSExpression expressionForKeyPath:attributeName]]];
    
    NSExpressionDescription *ed = [[NSExpressionDescription alloc] init];
    [ed setName:@"result"];
    [ed setExpression:ex];
    [ed setExpressionResultType:NSInteger64AttributeType];
    
    NSArray *properties = [NSArray arrayWithObject:ed];
    [ed release];
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setPropertiesToFetch:properties];
    [request setResultType:NSDictionaryResultType];
    
    if (predicate != nil)
        [request setPredicate:predicate];
    
    NSEntityDescription *entity = [NSEntityDescription entityForName:[self description]
                                              inManagedObjectContext:context];
    [request setEntity:entity];
    
    NSArray *results = [context executeFetchRequest:request error:nil];
    NSDictionary *resultsDictionary = [results objectAtIndex:0];
    NSNumber *resultValue = [resultsDictionary objectForKey:@"result"];
    [request release];
    return resultValue;
    
}
@end