#import <UIKit/UIKit.h>


@interface ForwardingLabel : UILabel {
	UIView* forwardee;
}

@property(retain) UIView* forwardee;

@end
