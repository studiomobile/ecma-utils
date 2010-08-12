#import <UIKit/UIKit.h>

@interface KeyboardAvoider : UIScrollView {
	CGRect keyboardFrame;
	UIView *focusedTextField;
	BOOL placeFocusedControlOverKeyboard;
}
@property (assign) BOOL placeFocusedControlOverKeyboard;

- (void)resetScroll;
- (void)scrollToField:(UIView*)focusedTextField;
- (void)scrollToField:(UIView*)focusedTextField keyboardHeight:(CGFloat)height;

@end
