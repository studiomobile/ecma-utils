#import "UIAlertView+Utils.h"

@implementation UIAlertView (Utils)

+ (UIAlertView*)createAlertViewWithTitle:(NSString*)title message:(NSString*)message {
	return [[UIAlertView alloc] initWithTitle:title 
                                      message:message 
                                     delegate:nil 
                            cancelButtonTitle:@"Dismiss" 
                            otherButtonTitles:nil];
}


+ (void)showAlertViewWithTitle:(NSString*)title message:(NSString*)message {
	[[[self createAlertViewWithTitle: title message: message] autorelease] show];
}


+ (void)showAlertViewWithMessage:(NSString*)message{
	[self showAlertViewWithTitle:nil message:message];
}


+ (void)showAlertViewWithTitle:(NSString*)title {
	[self showAlertViewWithTitle:title message:nil];
}

@end
