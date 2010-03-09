#import <UIKit/UIKit.h>

#define FORM_CONTROLLER_CONTROLS_TOP_MARGIN 10

@interface FormController : UIViewController<UITextFieldDelegate> {
	UITextField *focusedTextField;
	BOOL keyboardShown;
	CGRect oldTblViewFrame;
	BOOL tableViewResized;
    UIColor *superviewBackground;
}
@property (nonatomic, retain) UITableView *table;
@property (readonly) BOOL keyboardShown;

- (void)hideKeyboard;
- (void)changeTableFrame:(CGRect)newFrame;
- (void)restoreTableFrame:(BOOL)animated;
- (void)adjustTableRelativeToFrame:(CGRect)frame frameView:(UIView*)view;

- (BOOL)validateTextInput:(UITextField*)textField;

- (void)kbdWillShow:(NSNotification*)notification;
- (void)kbdDidShow;
- (void)kbdWillHide:(NSNotification*)notification;
- (void)kbdDidHide;

- (void)editingStarted:(NSNotification*)notification;
- (void)editingFinished:(NSNotification*)notification;

- (void)scrollToField:(NSIndexPath*)indexPath animated:(BOOL)animated;
- (void)scrollToFocusedTextField:(BOOL)animated;

- (NSIndexPath*)indexPathOfSelectedTextField;
@end
