#import "FormController.h"
#import "NSObject+Utils.h"
#import "UIApplication+Utils.h"

#define KEYBOARD_MARGIN 10

@interface FormController (Private)

@property (retain) UITextField *focusedTextField;

@end

@implementation FormController (Private)

- (UITextField*)focusedTextField {
    return focusedTextField;
}


- (void)setFocusedTextField:(UITextField*)fTF {
    if(fTF != focusedTextField) {
        [focusedTextField release];
        focusedTextField = [fTF retain];
    }
}


@end


@implementation FormController

@synthesize keyboardShown;

- (id)init {
	if (self = [super init]) {
	}
	return self;
}


- (id)initWithNibName:(NSString *)nibName bundle:(NSBundle *)nibBundle {
	if(self = [super initWithNibName:nibName bundle:nibBundle]) {
	}
	return self;
}


- (void)dealloc {
    [focusedTextField release];
    
    [super dealloc];
}


- (void)awakeFromNib {
	[super awakeFromNib];
}


- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];

	keyboardShown = NO;
	NSNotificationCenter *notifications = [NSNotificationCenter defaultCenter];
	[notifications addObserver:self selector:@selector(kbdWillShow:) name:UIKeyboardWillShowNotification object:nil];
	[notifications addObserver:self selector:@selector(kbdDidShow) name:UIKeyboardDidShowNotification object:nil];
	[notifications addObserver:self selector:@selector(kbdWillHide:) name:UIKeyboardWillHideNotification object:nil];
	[notifications addObserver:self selector:@selector(kbdDidHide) name:UIKeyboardDidHideNotification object:nil];
	[notifications addObserver:self selector:@selector(editingStarted:) name:UITextFieldTextDidBeginEditingNotification object:nil];
	[notifications addObserver:self selector:@selector(editingFinished:) name:UITextFieldTextDidEndEditingNotification object:nil];	
}


- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];

	NSNotificationCenter *notifications = [NSNotificationCenter defaultCenter];
	[notifications removeObserver:self name:UIKeyboardWillShowNotification object:nil];
	[notifications removeObserver:self name:UIKeyboardDidShowNotification object:nil];
	[notifications removeObserver:self name:UIKeyboardWillHideNotification object:nil];
	[notifications removeObserver:self name:UIKeyboardDidHideNotification object:nil];
	[notifications removeObserver:self name:UITextFieldTextDidBeginEditingNotification object:nil];
	[notifications removeObserver:self name:UITextFieldTextDidEndEditingNotification object:nil];
}


- (void)changeTableFrame:(CGRect)newFrame {
	if(tableViewResized) {
        return;
    }
    
    oldTblViewFrame = self.table.frame;
    tableViewResized = YES;
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration: 0.3];	
    self.table.frame = newFrame;
	[UIView commitAnimations];
}


- (void)adjustTableRelativeToFrame:(CGRect)frame frameView:(UIView*)view {
	CGRect tableFrameInView = [self.table convertRect:self.table.bounds toView:view];
	CGRect intersection = CGRectIntersection(frame, tableFrameInView);

	if(!CGRectIsNull(intersection)) {
		CGRect newTableFrameInView, slice;
		CGRectDivide(tableFrameInView, &slice, &newTableFrameInView, CGRectGetHeight(intersection), CGRectMaxYEdge);
		CGRect newTableFrame = [view convertRect:newTableFrameInView toView:self.table.superview];
        [self changeTableFrame:newTableFrame];
	}
}


- (void)restoreTableFrame:(BOOL)animated {
	if(tableViewResized) {
		tableViewResized = NO;        
		self.table.frame = oldTblViewFrame;        
	}
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
    
	CGRect kbdAppFrame = CGRectOffset(kbdBounds, kbdCenter.x - kbdBounds.size.width/2, kbdCenter.y - kbdBounds.size.height/2);
    CGRect restrictedFrame = CGRectMake(kbdAppFrame.origin.x, kbdAppFrame.origin.y - KEYBOARD_MARGIN, kbdAppFrame.size.width, kbdAppFrame.size.height + KEYBOARD_MARGIN);

    [self adjustTableRelativeToFrame:restrictedFrame frameView:[UIApplication mainView]];
    return;
}


- (void)kbdDidShow {
	keyboardShown = TRUE;
    //superviewBackground = [self.table.superview.backgroundColor retain];
    //self.table.superview.backgroundColor = self.table.backgroundColor;
}


- (void)kbdWillHide:(NSNotification*)notification {
	//Do not use this method to resize tableView.
	//This is because this method is called not only then keyboard are going to hide
	//but also when user taps on a text field while another one is focused.
	//In this situation system call kbdWillHide and just after it calls kbdWillShow. Note that kbdDidShow and kbdDidHide is not called.
	//And if you try to resize table view here it will be resized once again in kbdWillShow method.
	//Consiquently this double resizing causes table view to scroll up down which is very confusing for user.
	//(averbin)
}


- (void)kbdDidHide {
	keyboardShown = FALSE;
}


- (void)textFieldSelected {
}


- (void)editingStarted:(NSNotification*)notification {
	self.focusedTextField = (UITextField*)[notification object];
    [self scrollToFocusedTextField:YES];

    [self textFieldSelected];
}


- (void)editingFinished:(NSNotification*)notification {
    [self hideKeyboard];
}


- (void)scrollToField:(NSIndexPath*)indexPath animated:(BOOL)animated {
    [self.table scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionMiddle animated:YES];		
}


- (NSIndexPath*)indexPathOfSelectedTextField {
    if(!self.focusedTextField) return nil;
    
    UIView *cell = self.focusedTextField;
    do {
        cell = cell.superview;
    } while(![cell isKindOfClass:[UITableViewCell class]] && cell != nil);
    
    return [self.table indexPathForCell:(UITableViewCell*)cell];
}


- (void)scrollToFocusedTextField:(BOOL)animated  {
	if(self.focusedTextField) {
		[self scrollToField:[self indexPathOfSelectedTextField] animated:animated];		
	}
}


- (void)hideKeyboard {
	if(keyboardShown && self.focusedTextField) {
        [self restoreTableFrame:YES];

        UITextField *field = [self.focusedTextField retain];
        self.focusedTextField = nil;
		[field resignFirstResponder];
        [field release];
	}
}


- (BOOL)textFieldShouldReturn:(UITextField *)textField {
	return [self validateTextInput:textField];
}


- (BOOL)validateTextInput:(UITextField*)textField {
	return YES;
}


- (UITableView*)table {
	[NSException raise:@"InvalidStateException" format:@"!!!!Override table method!!!!"];
    return nil;
}


- (void)setTable:(UITableView*)tv {
}



@end

