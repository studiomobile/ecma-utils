#import "NSError+Utils.h"


@implementation NSError(Utils)

+(NSError*) errorWithDomain: (NSString*)domain code: (NSInteger) code description: (NSString*) description {
	NSDictionary *userInfo = [NSDictionary dictionaryWithObject:description forKey:NSLocalizedDescriptionKey];
	return [NSError errorWithDomain:domain code:code userInfo:userInfo]; 
}


- (void)display:(NSString*)actionDescription {
    UIAlertView *errorDisplay = [[UIAlertView alloc] init];
    errorDisplay.title = @"Error";
    NSString *errorMessage;
    if (actionDescription) {
        errorMessage = [NSString stringWithFormat:@"%@: \n%@", actionDescription, [self localizedDescription]];
    } else {
        errorMessage = [self localizedDescription];
    }
    NSLog(errorMessage);
    errorDisplay.message = errorMessage;
    [errorDisplay addButtonWithTitle:@"OK"];
    [errorDisplay show];
    [errorDisplay release];
}

@end
