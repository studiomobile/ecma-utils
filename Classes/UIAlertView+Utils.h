#import <UIKit/UIKit.h>

@interface UIAlertView (Utils)

+ (UIAlertView*)alertViewWithErrorMessage:(NSString*)message;
+ (UIAlertView*)alertViewWithMessage: (NSString*)message;
+ (UIAlertView*)alertViewWithTitle:(NSString*)title;
+ (UIAlertView*)alertViewWithTitle:(NSString*)title message:(NSString*)message;
+ (UIAlertView*)yesNoAlertViewWithTitle:(NSString*)title message:(NSString*)message;
+ (UIAlertView*)showOneButtonAlertViewWithTitle:(NSString *)title message:(NSString *)message delegate:(id)delegate;

+ (void)showAlertViewErrorMessage:(NSString*)message;
+ (void)showAlertViewWithMessage:(NSString*)message;
+ (void)showAlertViewWithTitle:(NSString*)title message:(NSString*)message;
+ (void)showAlertViewWithTitle:(NSString*)title;
+ (void)showYesNoAlertViewWithTitle:(NSString*)title message:(NSString*)message delegate:(id)delegate;


-(void)showAndCall: (SEL)selector of: (id)obj;
-(void)showAndCall: (SEL)selector of: (id)obj withArgument: (id)arg;

@end
