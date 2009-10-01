#import "UIAlertView+Utils.h"

@implementation UIAlertView (Utils)


+ (void)showAlertViewWithTitle:(NSString*)title message:(NSString*)message {
    UIAlertView *alert = [[[UIAlertView alloc] initWithTitle:title
                                                     message:message
                                                    delegate:nil
                                           cancelButtonTitle:@"OK"
                                           otherButtonTitles:nil] autorelease];
    
    [alert performSelectorOnMainThread:@selector(show) withObject:nil waitUntilDone:NO];
}


+ (void)showAlertViewWithMessage:(NSString*)message{
	[self showAlertViewWithTitle:nil message:message];
}


+ (void)showAlertViewWithTitle:(NSString*)title {
	[self showAlertViewWithTitle:title message:nil];
}


+ (void)showYesNoAlertViewWithTitle:(NSString*)title message:(NSString*)message delegate:(id)delegate {
    [[[[UIAlertView alloc] initWithTitle:title
                                 message:message
                                delegate:delegate
                       cancelButtonTitle:@"No"
                       otherButtonTitles:@"Yes", nil] autorelease] show];
}


@end
