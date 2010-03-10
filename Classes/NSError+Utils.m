#import "NSError+Utils.h"
#import "UIAlertView+Utils.h"
#import "NSArray+Utils.h"


@implementation NSError(Utils)

+ (NSError*) errorWithDomain:(NSString*)domain code:(NSInteger)code description:(NSString*)description {
	NSDictionary *userInfo = [NSDictionary dictionaryWithObject:description forKey:NSLocalizedDescriptionKey];
	return [NSError errorWithDomain:domain code:code userInfo:userInfo]; 
}


+ (NSError *)errorWithValue:(id)value forKey:(NSString *)keyName {
	NSDictionary *info = [NSDictionary dictionaryWithObject:value forKey:keyName];
	NSError *error = [NSError errorWithDomain:@"NonTitledDomain" code:0 userInfo:info];
	return error;
}


+ (NSError *)errorWithValue:(id)value forKey:(NSString *)keyName fromError:(NSError *)error {
	NSMutableDictionary *info = [NSMutableDictionary dictionaryWithDictionary:error.userInfo];
	[info setValue:value forKey:keyName];
	return [NSError errorWithDomain:error.domain code:error.code userInfo:info];
}


- (void)display { [self display:nil]; }
- (void)display:(NSString*)actionDescription {
    NSString *errorMessage;
    if (actionDescription) {
        errorMessage = [NSString stringWithFormat:@"%@: \n%@", actionDescription, [self localizedDescription]];
    } else {
        errorMessage = [self localizedDescription];
    }
    NSLog(@"%@", errorMessage);
	[UIAlertView showAlertViewErrorMessage: errorMessage];
}

@end

@implementation NSError (DetailedDescription)

- (NSString*)detailedDescription {	
	NSString *message = [NSString stringWithFormat:@"domain:%@ code:%d message:%@", self.domain, self.code, [self localizedDescription]];
	NSMutableArray *messages = [NSMutableArray array];	
	
	NSString *sub = nil;
	if([self respondsToSelector:@selector(detailedCoreDataDescription)]){
		sub = [self performSelector:@selector(detailedCoreDataDescription)];
		if(sub) [messages addObject:sub];
	}
	
	if([self respondsToSelector:@selector(detailedRESTDescription)]){
		sub = [self performSelector:@selector(detailedRESTDescription)];
		if(sub) [messages addObject:sub];
	}
	
	if(messages.count > 0){
		message = [message stringByAppendingFormat:@"\nDetailed description:\n%@", [messages joinWith:@"\n"]];
	}
	
	return  message;
}

- (void) displayDetailedDescription {
	[UIAlertView showAlertViewWithTitle:@"Error" message:[self detailedDescription]];
}

- (NSString *)platformDependentDescription {
	NSString *description = nil;
#if TARGET_IPHONE_SIMULATOR > 0 || defined(DEBUG_DETAILED_ERROR_DESCRIPTION)
	description = [self detailedDescription];
	NSLog(@"%@", description);
#else
	description = [self localizedDescription];				   
#endif
	return description;
}

- (void)displayPlatformDependentDescription{
	[UIAlertView showAlertViewWithTitle:@"Error" message:[self platformDependentDescription]];
}

@end
