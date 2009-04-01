#import "UIAlertView+Utils.h"

@implementation UIAlertView (Utils)

+(UIAlertView*)createAlertViewWithTitle: (NSString*)title message: (NSString*)message{
	UIAlertView* alert = [[UIAlertView alloc]initWithTitle:title message:message delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
	return alert;
}

+(void)showAlertViewWithTitle: (NSString*)title message: (NSString*)message{
	[[[self createAlertViewWithTitle: title message: message]autorelease]show];
}


+(void)showAlertViewWithMessage: (NSString*)message{
	[self showAlertViewWithTitle:nil message:message];
}

@end
