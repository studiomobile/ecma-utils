#import "UIBlockingView.h"

@interface UIBlocker : NSObject<UIBlockingView>{
	UIActivityIndicatorView* indicator;
	UIActivityIndicatorView* myIndicator;
	NSArray* views;
	NSMutableDictionary* viewStates;
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
