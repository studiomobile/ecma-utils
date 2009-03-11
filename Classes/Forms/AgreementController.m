#import "AgreementController.h"
#import "NSString+Utils.h"

@implementation AgreementController

@synthesize title;
@synthesize dataSource;
@synthesize keyPath;
@synthesize html;

- (id)initWithTitle:(NSString*)aTitle {
	if (self = [super init]) {
		title = [aTitle retain];
	}
	return self;
}

- (void)loadView {
	webView = [UIWebView new];
	webView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleBottomMargin;
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://localhost/%@", [title urlEncode]]];
	[webView loadHTMLString:html baseURL:url];
	
	UIView *view = [[UIView new] autorelease];
	[view addSubview:webView];
	view.frame = self.parentViewController.view.bounds;
	view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleBottomMargin;
	self.view = view;
}

- (void)viewDidLoad {
	self.navigationItem.hidesBackButton = YES;
	self.navigationItem.title = title;
	self.navigationItem.leftBarButtonItem = [[[UIBarButtonItem alloc] initWithTitle:@"Decline" style:UIBarButtonItemStyleBordered target:self action:@selector(decline)] autorelease];
	self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithTitle:@"Accept" style:UIBarButtonItemStyleBordered target:self action:@selector(accept)] autorelease];
}

- (void)done:(BOOL)accepted {
    [dataSource setValue:[NSNumber numberWithBool:accepted] forKeyPath:keyPath];
	[self.navigationController popViewControllerAnimated:YES];
}

- (void)accept {
	[self done:YES];
}

- (void)decline {
	[self done:NO];
}

- (void)viewDidAppear:(BOOL)animated {
	navigationBarWasHidden = self.navigationController.navigationBarHidden;
	self.navigationController.navigationBarHidden = NO;
}

- (void)viewWillDisappear:(BOOL)animated {
	self.navigationController.navigationBarHidden = navigationBarWasHidden;
    [super viewWillDisappear:animated];
}

- (void)dealloc {
	[webView release];
	[title release];
	[keyPath release];
    [html release];
    [super dealloc];
}


@end
