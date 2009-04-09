#import "NSError+Utils.h"
#import "UIAlertView+Utils.h"


@implementation NSError(Utils)

+(NSError*) errorWithDomain: (NSString*)domain code: (NSInteger) code description: (NSString*) description {
	NSDictionary *userInfo = [NSDictionary dictionaryWithObject:description forKey:NSLocalizedDescriptionKey];
	return [NSError errorWithDomain:domain code:code userInfo:userInfo]; 
}

-(void)display{
	[self display:nil];
}

- (void)display:(NSString*)actionDescription {
    NSString *errorMessage;
    if (actionDescription) {
        errorMessage = [NSString stringWithFormat:@"%@: \n%@", actionDescription, [self localizedDescription]];
    } else {
        errorMessage = [self localizedDescription];
    }
    NSLog(errorMessage);
	[UIAlertView showAlertViewWithTitle:@"Error" message: errorMessage];
}

@end
