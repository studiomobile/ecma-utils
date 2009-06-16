#import "UIView+Rotation.h"

@implementation UIView (Rotation)

- (void)rotateViewToOrientation:(UIInterfaceOrientation)orientation animated:(BOOL)animated {
	CGPoint center = self.center;
	CGRect bounds = self.bounds;
	CGAffineTransform transform = CGAffineTransformIdentity;
	switch (orientation) {
		case UIInterfaceOrientationPortraitUpsideDown: 
			transform = CGAffineTransformMakeRotation(M_PI);
			break;
		case UIInterfaceOrientationLandscapeLeft:
			transform = CGAffineTransformMakeRotation(-M_PI_2);
			break;
		case UIInterfaceOrientationLandscapeRight:
			transform = CGAffineTransformMakeRotation(M_PI_2);
			break;
	}
	if (animated) {
		[UIView beginAnimations:nil context:nil];
	}
	self.transform = transform;
	bounds = CGRectApplyAffineTransform(bounds, transform);
	self.bounds = CGRectMake(0, 0, bounds.size.width, bounds.size.height);
	self.center = center;
	if (animated) {
		[UIView commitAnimations];
	}
}

@end
