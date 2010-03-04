
#import "UIViewController+NIB.h"


@implementation UIViewController(NIB)

- (void)replacePlaceholderView:(UIView*)v fromNibNamed:(NSString*)name {

	NSAssert(![self isViewLoaded], @"Receiver's view must not yet be loaded");

	UIView *sv = [v superview];
	CGRect frame = v.frame;
	[v removeFromSuperview];
	[[NSBundle mainBundle] loadNibNamed:name owner:self options:nil];
	self.view.frame = frame;
	[sv addSubview:self.view];
	[self viewDidLoad];
}	

- (void)replacePlaceholderViewFromOwnNib: (UIView*)v {
	[self replacePlaceholderView:v fromNibNamed:[[self class] description]];
}

@end
