#import <UIKit/UIKit.h>


@interface FormController : UIViewController<UITextFieldDelegate> {
	UITextField *focusedTextField;
	BOOL keyboardShown;
	CGRect oldTblViewFrame;
	BOOL tableViewResized;
    UIColor *superviewBackground;
}
@property (nonatomic, retain) UITableView *table;

- (void)hideKeyboard;
- (BOOL)validateTextInput:(UITextField*)textField;

- (void)kbdWillShow:(NSNotification*)notification;
- (void)kbdDidShow;
- (void)kbdWillHide:(NSNotification*)notification;
- (void)kbdDidHide;

- (void)editingStarted:(NSNotification*)notification;
- (void)editingFinished:(NSNotification*)notification;

- (void)scrollToField:(NSIndexPath*)indexPath animated:(BOOL)animated;
- (void)scrollToFocusedTextField:(BOOL)animated;

@end
