#import <UIKit/UIKit.h>


@interface KeyboardAvoider : UIScrollView {
	CGRect keyboardFrame;
	
	BOOL placeFocusedControlOverKeyboard;
}

@property(assign) BOOL placeFocusedControlOverKeyboard;

- (void)resetScroll;
- (void)scrollToField:(UIView*)focusedTextField;

@end
