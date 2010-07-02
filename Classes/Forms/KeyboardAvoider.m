#import "KeyboardAvoider.h"
#import "UIApplication+Utils.h"

@implementation KeyboardAvoider

@synthesize placeFocusedControlOverKeyboard;

-(void)privateInit{
	NSNotificationCenter *notifications = [NSNotificationCenter defaultCenter];
	[notifications addObserver:self selector:@selector(kbdWillShow:) name:UIKeyboardWillShowNotification object:nil];
	[notifications addObserver:self selector:@selector(editingStarted:) name:UITextFieldTextDidBeginEditingNotification object:nil];
	[notifications addObserver:self selector:@selector(editingFinished:) name:UITextFieldTextDidEndEditingNotification object:nil];		
}


-(void)awakeFromNib{
	[super awakeFromNib];
	[self privateInit];
}


- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
		[self privateInit];
    }
    return self;
}


- (void)dealloc {
	NSNotificationCenter *notifications = [NSNotificationCenter defaultCenter];
	[notifications removeObserver:self name:UIKeyboardWillShowNotification object:nil];
	[notifications removeObserver:self name:UITextFieldTextDidBeginEditingNotification object:nil];
	[notifications removeObserver:self name:UITextFieldTextDidEndEditingNotification object:nil];	
	
    [super dealloc];
}

#pragma mark private

- (void)resetScroll {
	[self setContentOffset:CGPointZero animated: YES];
}


-(void)scrollToField: (UIView*)textField{
	if(![textField isDescendantOfView:self])
		return;
	
	UIView* main = [UIApplication mainView];
	
	CGRect scrollRectAbsolute = [self.superview convertRect:self.frame toView:main];
	float freeAreaTop = CGRectGetMinY(scrollRectAbsolute);
	float freeAreaBottom = CGRectGetMinY(keyboardFrame);
	CGRect fieldRectAbsolute = [[UIApplication mainView] convertRect: textField.bounds fromView: textField];
	
	float pointToScrollTo;	
	if(placeFocusedControlOverKeyboard){
		float fieldHeight = CGRectGetHeight(fieldRectAbsolute);
		pointToScrollTo = freeAreaBottom - 5 - fieldHeight/2;
	} else {
		pointToScrollTo = (freeAreaTop + freeAreaBottom)/2;	
	}	
	
	float delta = pointToScrollTo - CGRectGetMidY(fieldRectAbsolute);
	float offset = self.contentOffset.y - delta;		
	
	[self setContentOffset: CGPointMake(0, offset) animated:YES];
}


-(CGRect)extractKeyboardFrameFromNotification: (NSNotification*)notification{
	NSDictionary *userInfo = notification.userInfo;
	NSValue *kbdBoundsValue = [userInfo objectForKey:UIKeyboardBoundsUserInfoKey];
	CGRect kbdBounds;
	[kbdBoundsValue getValue:&kbdBounds];
	NSValue *kbdEndCenterValue = [userInfo objectForKey:UIKeyboardCenterEndUserInfoKey];
	CGPoint kbdCenter;
	[kbdEndCenterValue getValue:&kbdCenter];
	
	CGRect kbdAppFrame = CGRectOffset(kbdBounds, kbdCenter.x - kbdBounds.size.width/2, kbdCenter.y - kbdBounds.size.height/2);
		
	return kbdAppFrame;
}

#pragma mark keyboard & text fields notification handlers

- (void)kbdWillShow:(NSNotification*)notification {
    keyboardFrame = [self extractKeyboardFrameFromNotification:notification];
	//works for iOS 4.0. kbdWillShow and editingStarted are called in different orders in iOS 4.0 and 3.1.3 devices
	//(averbin)
	if (focusedTextField) {
		[self scrollToField: focusedTextField];
	}
}


- (void)kbdWillHide:(NSNotification*)notification {	
}


- (void)editingStarted:(NSNotification*)notification {
	focusedTextField = (UIView*)[notification object];
	//This works for pre iOS 4.0 devices. kbdWillShow and editingStarted are called in different orders in iOS 4.0 and 3.1.3 devices
	//(averbin)
	if (!CGRectEqualToRect(CGRectZero, keyboardFrame)) {
		[self scrollToField:focusedTextField];
	}
}


- (void)editingFinished:(NSNotification*)notification {
	focusedTextField = nil;
	keyboardFrame = CGRectZero;
	[NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(checkResetScroll) userInfo:nil repeats:NO];
}


- (void)checkResetScroll {
	if (!focusedTextField) {
		[self resetScroll];
	}
}


@end
