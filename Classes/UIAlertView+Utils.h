#import <UIKit/UIKit.h>

@interface UIAlertView (Utils)

+ (void)showAlertViewWithMessage:(NSString*)message;
+ (void)showAlertViewWithTitle:(NSString*)title message:(NSString*)message;
+ (void)showAlertViewWithTitle:(NSString*)title;
+ (void)showYesNoAlertViewWithTitle:(NSString*)title message:(NSString*)message delegate:(id)delegate;

@end
