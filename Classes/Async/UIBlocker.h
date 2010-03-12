#import "UIBlockingView.h"
#import <UIKit/UIKit.h>

@interface UIBlocker : NSObject<UIBlockingView>{
	UIActivityIndicatorView* indicator;
	UIActivityIndicatorView* myIndicator;
	NSArray* views;
    BOOL dontShowIndicator;
    BOOL blockInteraction;
}
@property (retain) UIActivityIndicatorView* indicator;
@property (copy) NSArray* views;
@property (assign) BOOL blockInteraction;

+ (UIBlocker*)blocker;
+ (UIBlocker*)blockerForView:(UIView*)view;

-(void) dontShowIndicator;

@end
