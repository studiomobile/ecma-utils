#import "UIAlertView+Utils.h"

@implementation UIAlertView (Utils)


+ (void)showAlertViewErrorMessage:(NSString*)message {
    [self showAlertViewWithTitle:NSLocalizedString(@"Error", nil) message:message];
}


+ (void)showAlertViewWithTitle:(NSString*)title message:(NSString*)message {
    UIAlertView *alert = [[[UIAlertView alloc] initWithTitle:title
                                                     message:message
                                                    delegate:nil
                                           cancelButtonTitle:NSLocalizedString(@"OK", nil)
                                           otherButtonTitles:nil] autorelease];
    
    [alert performSelectorOnMainThread:@selector(show) withObject:nil waitUntilDone:NO];
}


+ (void)showAlertViewWithMessage:(NSString*)message {
	[self showAlertViewWithTitle:nil message:message];
}


+ (void)showAlertViewWithTitle:(NSString*)title {
	[self showAlertViewWithTitle:title message:nil];
}


+ (void)showYesNoAlertViewWithTitle:(NSString*)title message:(NSString*)message delegate:(id)delegate {
    [[[[UIAlertView alloc] initWithTitle:title
                                 message:message
                                delegate:delegate
                       cancelButtonTitle:NSLocalizedString(@"No", nil)
                       otherButtonTitles:NSLocalizedString(@"Yes", nil), nil] autorelease] show];
}


@end
