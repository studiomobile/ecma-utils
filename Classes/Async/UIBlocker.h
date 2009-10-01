#import "UIBlockingView.h"

@interface UIBlocker : NSObject<UIBlockingView>{
	UIActivityIndicatorView* indicator;
	UIActivityIndicatorView* myIndicator;
	NSArray* views;
	NSMutableDictionary* viewStates;
    BOOL showGlobalIndicator;
    BOOL blockInteraction;
}
@property (retain) UIActivityIndicatorView* indicator;
@property (copy) NSArray* views;
@property (assign) BOOL showGlobalIndicator;
@property (assign) BOOL blockInteraction;

+ (UIBlocker*)blocker;
+ (UIBlocker*)blockerForView:(UIView*)view;

@end
