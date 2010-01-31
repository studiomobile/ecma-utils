#import "NSError+Utils.h"
#import "UIAlertView+Utils.h"


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
