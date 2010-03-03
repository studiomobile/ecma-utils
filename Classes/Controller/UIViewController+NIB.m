
#import "UIViewController+NIB.h"


@implementation UIViewController(NIB)

- (void)replaceViewFromNibNamed:(NSString*)name {
	UIView *v = self.view;
	UIView *sv = [v superview];
	CGRect frame = v.frame;
	self.view = nil;
	[v removeFromSuperview];
	[[NSBundle mainBundle] loadNibNamed:name owner:self options:nil];
	self.view.frame = frame;
	[sv addSubview:self.view];	
}	

- (void)replaceViewFromOwnNib {
	[self replaceViewFromNibNamed:[[self class] description]];
}

@end
