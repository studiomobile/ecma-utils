#import "NSError+CoreData.h"
#import <CoreData/CoreData.h>
#import "NSError+Utils.h"
#import "NSArray+Utils.h"

@implementation NSError(CoreData)

- (NSString*)detailedCoreDataDescription {
	NSDictionary *info = self.userInfo;
	NSMutableArray *messages = [NSMutableArray array];
	
	NSArray *subErrors = [info objectForKey:NSDetailedErrorsKey];
	if(subErrors){		
		[messages addObject: @"Multiple errors occured:"];
		for (NSError *e in subErrors) {
			[messages addObject:[e detailedDescription]];
		}
	}
	
	id obj = [info objectForKey:NSValidationObjectErrorKey];
	if(obj)	[messages addObject:[NSString stringWithFormat:@"Validation error object: %@", [obj class]]];
	id key = [info objectForKey:NSValidationKeyErrorKey];
	if(key)	[messages addObject:[NSString stringWithFormat:@"Validation error key: %@", key]];
	id val = [info objectForKey:NSValidationValueErrorKey];
	if(val)	[messages addObject:[NSString stringWithFormat:@"Validation error value: %@", [val class]]];
	id pred = [info objectForKey:NSValidationPredicateErrorKey];
	if(pred)	[messages addObject:[NSString stringWithFormat:@"Validation error predicate: %@", pred]];
	NSArray *objs = [info objectForKey:NSAffectedObjectsErrorKey];
	if(objs){
		NSArray *classes = [objs collect:@"class"];
		NSString *descr = [classes joinWith:@", "];
		[messages addObject:[NSString stringWithFormat:@"Affected objects: %@", descr]];
	}
	
	if(messages.count > 0) return [messages joinWith:@"\n"];
	else return nil;
}

@end
