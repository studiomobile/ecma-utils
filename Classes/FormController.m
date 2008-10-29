#import "FormController.h"
#import "NSObject+Utils.h"
#import "UIApplication+Utils.h"

@implementation FormController

- (void)initFields {
	tableViewResized = NO;
	keyboardShown = NO;
	NSNotificationCenter *notifications = [NSNotificationCenter defaultCenter];
	[notifications addObserver:self selector:@selector(kbdWillShow:) name:UIKeyboardWillShowNotification object:nil];
	[notifications addObserver:self selector:@selector(kbdDidShow) name:UIKeyboardDidShowNotification object:nil];
	[notifications addObserver:self selector:@selector(kbdWillHide:) name:UIKeyboardWillHideNotification object:nil];
	[notifications addObserver:self selector:@selector(kbdDidHide) name:UIKeyboardDidHideNotification object:nil];
	[notifications addObserver:self selector:@selector(editingStarted:) name:UITextFieldTextDidBeginEditingNotification object:nil];
	[notifications addObserver:self selector:@selector(editingFinished:) name:UITextFieldTextDidEndEditingNotification object:nil];	
}

- (id)init {
	if (self = [super init]) {
		[self initFields];
	}
	return self;
}

- (id)initWithNibName:(NSString *)nibName bundle:(NSBundle *)nibBundle {
	if(self = [super initWithNibName:nibName bundle:nibBundle]) {
		[self initFields];
	}
	return self;
}

- (void)awakeFromNib {
	[super awakeFromNib];
	[self initFields];
}

- (void)dealloc {
	NSNotificationCenter *notifications = [NSNotificationCenter defaultCenter];
	[notifications removeObserver:self name:UIKeyboardWillShowNotification object:nil];
	[notifications removeObserver:self name:UIKeyboardDidShowNotification object:nil];
	[notifications removeObserver:self name:UIKeyboardWillHideNotification object:nil];
	[notifications removeObserver:self name:UIKeyboardDidHideNotification object:nil];
	[notifications removeObserver:self name:UITextFieldTextDidBeginEditingNotification object:nil];
	[notifications removeObserver:self name:UITextFieldTextDidEndEditingNotification object:nil];
    [super dealloc];
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	
}

- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
}

- (void)kbdWillShow:(NSNotification*)notification {
	if(tableViewResized) { //if you want to understand why this if statement see comments in kbdWillHide
		return;
	}
	NSDictionary *userInfo = notification.userInfo;
	NSValue *kbdBoundsValue = [userInfo objectForKey:UIKeyboardBoundsUserInfoKey];
	CGRect kbdBounds;
	[kbdBoundsValue getValue:&kbdBounds];
	NSValue *kbdEndCenterValue = [userInfo objectForKey:UIKeyboardCenterEndUserInfoKey];
	CGPoint kbdCenter;
	[kbdEndCenterValue getValue:&kbdCenter];
	CGRect statusBarFrame = [[UIApplication sharedApplication] statusBarFrame];
	if(![UIApplication sharedApplication].statusBarHidden) {
		if(UIInterfaceOrientationIsPortrait([UIApplication sharedApplication].statusBarOrientation)){
			kbdCenter = CGPointMake(kbdCenter.x, kbdCenter.y - CGRectGetHeight(statusBarFrame));
		} else {
			kbdCenter = CGPointMake(kbdCenter.x, kbdCenter.y - CGRectGetWidth(statusBarFrame));
		}
	}
	
	UIView *appView = [UIApplication mainView];	
	CGRect kbdAppFrame = CGRectOffset(kbdBounds, kbdCenter.x - kbdBounds.size.width/2, kbdCenter.y - kbdBounds.size.height/2 );
	CGRect tblAppFrame = [self.tableView convertRect:self.tableView.bounds toView:appView];
	CGRect tblAndKbdIntersection = CGRectIntersection(kbdAppFrame, tblAppFrame);
	if(!CGRectIsNull(tblAndKbdIntersection)) {
		CGRect newTblAppFrame, slice;
		CGRectDivide(tblAppFrame, &slice, &newTblAppFrame, CGRectGetHeight(tblAndKbdIntersection), CGRectMaxYEdge);
		CGRect newTblFrame = [appView convertRect:newTblAppFrame toView:self.tableView];
		oldTblViewFrame = self.tableView.frame;
		tableViewResized = YES;
		[UIView beginAnimations: nil context: NULL];
		[UIView setAnimationDuration: 0.3];	
		[UIView setAnimationDelegate:self];
		self.tableView.frame = newTblFrame;
		[UIView commitAnimations];
	}
}

- (void)kbdDidShow {
	keyboardShown = TRUE;
}

- (void)kbdWillHide:(NSNotification*)notification {
	//Do not use this method to resize tableView.
	//This is because this method is called not only then keyboard are going to hide
	//but also when user taps on a text filed while another one is focused.
	//In this situation system call kbdWillHide and just after it calls kbdWillShow. Note that kbdDidShow and kbdDidHide is not called.
	//And if you try to resize table view here it will be resized once again in kbdWillShow method.
	//Consiquently this double resizing causes table view to scroll up down which is very confusing for user.
	//(averbin)
}

- (void)kbdDidHide {
	keyboardShown = FALSE;
	if(tableViewResized) {
		tableViewResized = NO;
		self.tableView.frame = oldTblViewFrame;
	}
}

- (void)editingStarted:(NSNotification*)notification {
	focusedTextField = (UITextField*)[notification object];
}

- (void)editingFinished:(NSNotification*)notification {
	focusedTextField = nil;
}

- (void)scrollToFocusedTextField:(BOOL)animated  {
	if(focusedTextField) {
		UIView *cell = focusedTextField;
		do {
			cell = cell.superview;
		} while(![cell isKindOfClass:[UITableViewCell class]] && cell != nil);
		
		NSIndexPath *path = [self.tableView indexPathForCell:(UITableViewCell*)cell];
		[self.tableView scrollToRowAtIndexPath:path atScrollPosition:UITableViewScrollPositionMiddle animated:animated];		
	}
}

- (void)hideKeyboard {
	if(keyboardShown && focusedTextField) {
		[focusedTextField resignFirstResponder];
	}
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
	if([self validateTextInput:textField]) {
		[self hideKeyboard];
		return YES;
	}
	return NO;
}

- (BOOL)validateTextInput:(UITextField*)textField {
	return YES;
}

@end

