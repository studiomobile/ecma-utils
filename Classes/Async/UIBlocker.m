#import "UIBlocker.h"

@interface UIBlocker ()

@property(retain) NSMutableDictionary* viewStates;

@end


@implementation UIBlocker

@synthesize viewStates;

#pragma mark private

-(UIActivityIndicatorView*)createIndicator{
	UIActivityIndicatorView* ind = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle: UIActivityIndicatorViewStyleWhiteLarge];
	ind.hidesWhenStopped = YES;
	ind.center = CGPointMake(320/2, 480/2);
	return ind;
}

-(void)installIndicator: (UIActivityIndicatorView*)ind{
	[[UIApplication sharedApplication].keyWindow addSubview: ind];
}

-(void)deinstallIndicator: (UIActivityIndicatorView*)ind{
	[ind removeFromSuperview];
}

-(void)blockViews{
	self.viewStates = [NSMutableDictionary dictionary];
	for(UIView* v in viewsToBlock){
		[viewStates setObject: [NSNumber numberWithBool: v.userInteractionEnabled] forKey: [NSNumber numberWithUnsignedInt: v.hash]];
		v.userInteractionEnabled = NO;
	}		
}

-(void)unblockViews{
	for(UIView* v in viewsToBlock){
		v.userInteractionEnabled = [[viewStates objectForKey: [NSNumber numberWithUnsignedInt: v.hash]] boolValue];		
	}
	self.viewStates = nil;
}


#pragma mark properties

-(UIActivityIndicatorView*)indicator{
	if(!indicator){
		indicator = [self createIndicator];
		isForeignIndicator = NO;
	}
	
	return indicator;
}

-(void)setIndicator: (UIActivityIndicatorView*)ind{
	[ind retain];
	[indicator release];
	indicator = ind;
	isForeignIndicator = YES;
}

-(NSArray*) views{
	return viewsToBlock;
}

-(void) setViews: (NSArray*) ar{
	NSMutableArray* copy = [ar mutableCopy];
	[viewsToBlock release];
	viewsToBlock = copy;	
}

-(UIView*)view{
	return viewsToBlock.count ? [viewsToBlock objectAtIndex:0] : nil;
}

-(void)setView: (UIView*)v{
	if(![viewsToBlock containsObject: v]){
		[viewsToBlock addObject: v];
	}
}

#pragma mark instance creation

+(UIBlocker*)blocker{
	return [[self new] autorelease];
}

+(UIBlocker*)blockerForView: (UIView*)view{
	UIBlocker* inst = [self blocker];
	inst.view = view;
	return inst;
}

		
#pragma mark NSObject
		
- (id) init{
	self = [super init];
	if (self != nil) {
		self.views = [NSArray array];
	}
	return self;
}

- (void) dealloc{
	[viewStates release];
	[viewsToBlock release];
	[indicator release];
	
	[super dealloc];
}

#pragma mark UIBlockingView

- (void)blockUI{
	[self blockViews];
}

- (void)unblockUI{
	[self unblockViews];
	
	[indicator stopAnimating];
	if(!isForeignIndicator){
		[self deinstallIndicator: self.indicator];
	}
}

- (void)showIndicator{
	if(!isForeignIndicator){
		[self installIndicator: self.indicator];
	}

	self.indicator.hidden = NO;		
	[indicator startAnimating];
}

@end