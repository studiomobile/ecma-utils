#import <UIKit/UIKit.h>


@interface FormController : UITableViewController<UITextFieldDelegate> {
	UITextField *focusedTextField;
	BOOL keyboardShown;
	CGRect oldTblViewFrame;
	BOOL tableViewResized;
}

- (void)hideKeyboard;
- (BOOL)validateTextInput:(UITextField*)textField;

- (void)kbdWillShow:(NSNotification*)notification;
- (void)kbdDidShow;
- (void)kbdWillHide:(NSNotification*)notification;
- (void)kbdDidHide;

- (void)editingStarted:(NSNotification*)notification;
- (void)editingFinished:(NSNotification*)notification;

- (void)scrollToFocusedTextField:(BOOL)animated;

@end
