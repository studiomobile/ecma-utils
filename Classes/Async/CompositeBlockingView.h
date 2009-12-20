#import "UIBlockingView.h"

@interface CompositeBlockingView : NSObject<UIBlockingView>{
	NSArray* blockers;
}

+(CompositeBlockingView*) compositeBlockingViewWithBlockers: (NSArray*)blockers;

@end
