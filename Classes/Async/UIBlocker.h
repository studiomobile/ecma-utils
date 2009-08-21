#import "UIBlockingView.h"

@interface UIBlocker : NSObject<UIBlockingView>{
	UIActivityIndicatorView* indicator;
	BOOL isForeignIndicator;
	
	NSMutableArray* viewsToBlock;
	NSMutableDictionary* viewStates;
}

@property(retain) UIActivityIndicatorView* indicator;
@property(copy) NSArray* views;
@property(retain) UIView* view;

+(UIBlocker*)blocker;
+(UIBlocker*)blockerForView: (UIView*)view;

@end
