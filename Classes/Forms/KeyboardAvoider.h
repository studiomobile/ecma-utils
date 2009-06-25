#import <UIKit/UIKit.h>


@interface KeyboardAvoider : UIScrollView {
	CGRect keyboardFrame;
	
	BOOL placeFocusedControlOverKeyboard;
}

@property(assign) BOOL placeFocusedControlOverKeyboard;

@end
