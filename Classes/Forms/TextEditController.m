#import "TextEditController.h"

@implementation TextEditController

@synthesize title;
@synthesize dataSource;
@synthesize keyPath;


- (id)initWithTitle:(NSString*)aTitle {
	if (self = [super init]) {
		title = [aTitle retain];
	}
	return self;
}

- (void)loadView {
	textView = [UITextView new];
	textView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleBottomMargin;
	textView.delegate = self;
	textView.text = [dataSource valueForKeyPath:keyPath];
	
	UIView *view = [[UIView new] autorelease];
	[view addSubview:textView];
	view.frame = self.parentViewController.view.bounds;
	self.view = view;
}


- (void)viewDidLoad {
	self.navigationItem.hidesBackButton = YES;
	self.navigationItem.title = title;
	self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(done)] autorelease];
}


- (void)done {
	self.navigationController.navigationBarHidden = navigationBarWasHidden;
	[self.navigationController popViewControllerAnimated:YES];
}


- (void)viewDidAppear:(BOOL)animated {
	navigationBarWasHidden = self.navigationController.navigationBarHidden;
	self.navigationController.navigationBarHidden = NO;
	
	[textView becomeFirstResponder];
	[UIView beginAnimations:nil context:nil];
	[UIView setAnimationDuration:0.4];
	CGRect textFrame = self.view.bounds;
	textFrame.size.height -= 160;
	textView.frame = textFrame;
	[UIView commitAnimations];
}


- (void)viewWillDisappear:(BOOL)animated {
	textView.delegate = nil;
}


- (void)textViewDidChange:(UITextView *)_textView {
	[dataSource setValue:textView.text forKeyPath:keyPath];
}


- (void)dealloc {
	[textView release];
	[title release];
	[keyPath release];
    [super dealloc];
}


@end
