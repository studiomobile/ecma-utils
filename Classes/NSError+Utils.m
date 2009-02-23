#import "NSError+Utils.h"


@implementation NSError(Utils)

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
