#import "UIApplication+Utils.h"
#import "NSObject+Utils.h"

@implementation UIApplication(Utils)

+ (id) delegate {
	return [[UIApplication sharedApplication] delegate];
}


+ (UIView*)mainView {
	UIApplication *app = [UIApplication sharedApplication];
	UIWindow *window = app.keyWindow;
	NSArray *subviews = [window subviews];
	checkState([subviews count] == 1, @"Cannot find main view because window contain several views");
	return [subviews objectAtIndex:0];
}

@end
