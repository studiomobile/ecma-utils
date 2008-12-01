#import "NSError+Utils.h"


@implementation NSError(Utils)

- (void)display:(NSString*)actionDescription {
	UIAlertView *errorDisplay = [[UIAlertView alloc] init];
	errorDisplay.title = @"Error";
	NSString *errorMessage = [NSString stringWithFormat:@"%@: \n%@", actionDescription, [self localizedDescription]];
	NSLog(errorMessage);
	errorDisplay.message = errorMessage;
	[errorDisplay addButtonWithTitle:@"OK"];
	[errorDisplay show];
	[errorDisplay release];
}

@end
