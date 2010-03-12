#import "UIBlocker.h"
#import "CGGeometry+Utils.h"

@interface ViewInfo : NSObject{
	BOOL originalUserInteractionEnabled;
	BOOL blockCount;
}

- (void)incrementBlockCount;
- (BOOL)decrementBlockCount;
- (void)restoreOriginalState:(UIView*)v;

@end

@implementation ViewInfo

- (id) initWithView:(UIView*)v{
	self = [super init];
	if (self != nil) {
		originalUserInteractionEnabled = v.userInteractionEnabled;
		blockCount = 0;
	}
	return self;
}

- (void)incrementBlockCount {
	blockCount++;
}

- (BOOL)decrementBlockCount {
	if(blockCount > 0)	blockCount--;
	return blockCount == 0;
}

- (void)restoreOriginalState:(UIView*)v {
	v.userInteractionEnabled = originalUserInteractionEnabled;
}


@end

/////////////////////////////////////////////////////////////////////////////////////////////////

@interface InteractionsBlockingService : NSObject{
	NSMutableDictionary *viewInfoByHash;
	
	BOOL originalIsIgnoringInteractionEvents;
	int blockInteractionsCounter;
}

- (void)blockView:(UIView*)v;
- (void)unblockView:(UIView*)v;

- (void)blockGlobalInteractions;
- (void)unblockGlobalInteractions;

@end

static InteractionsBlockingService *sharedInteractionsBlockingService;

@implementation InteractionsBlockingService

#pragma mark private

- (id)viewKey:(UIView*)v {
	return [NSNumber numberWithUnsignedInt:v.hash];			 
}

#pragma mark public

- (void)blockView:(UIView*)v {
	@synchronized(self) {
		id key = [self viewKey:v];
		ViewInfo* info = [viewInfoByHash objectForKey:key];
		if(!info) {
			info = [[ViewInfo alloc] initWithView:v];
			[viewInfoByHash setObject:info forKey:key];
			[info release];
			
			v.userInteractionEnabled = NO;
		}
		[info incrementBlockCount];
	}
}

- (void)unblockView:(UIView*)v {
	@synchronized(self) {
		id key = [self viewKey:v];
		ViewInfo* info = [viewInfoByHash objectForKey:key];
		if(!info) {
			return;
		}
		if([info decrementBlockCount]) {
			[info restoreOriginalState:v];
			[viewInfoByHash removeObjectForKey:key];
		}
	}	
}

- (void)blockGlobalInteractions {
	@synchronized(self) {
		if(blockInteractionsCounter == 0) {
			originalIsIgnoringInteractionEvents = [[UIApplication sharedApplication] isIgnoringInteractionEvents];
			if(!originalIsIgnoringInteractionEvents) {
				[[UIApplication sharedApplication] beginIgnoringInteractionEvents];
			}				
		}
		blockInteractionsCounter++;
	}
}
- (void)unblockGlobalInteractions {
	@synchronized(self) {
		if(blockInteractionsCounter > 0) blockInteractionsCounter--;
		if(blockInteractionsCounter == 0) {
			if([[UIApplication sharedApplication] isIgnoringInteractionEvents] != originalIsIgnoringInteractionEvents) {
				originalIsIgnoringInteractionEvents ?
				[[UIApplication sharedApplication] beginIgnoringInteractionEvents] :
				[[UIApplication sharedApplication] endIgnoringInteractionEvents];				
			}
		}
	}
}

#pragma mark singleton

- (id)init{
	NSAssert(NO, @"should not call");
	return nil;
}

- (id) privateInit{
	self = [super init];
	if (self != nil) {
		viewInfoByHash = [NSMutableDictionary new];
	}
	return self;
}


+ (InteractionsBlockingService *)sharedService {
	@synchronized(self) {
		if(sharedInteractionsBlockingService == nil) {
			[[self alloc] privateInit];
		}
	}
	return sharedInteractionsBlockingService;
}

+ (id)allocWithZone:(NSZone *)zone {
	@synchronized(self) {
		if(sharedInteractionsBlockingService == nil) {
			sharedInteractionsBlockingService = [super allocWithZone:zone];
			return sharedInteractionsBlockingService;
		}
	}
	return nil;
}

- (id)copyWithZone:(NSZone *)zone { return self; }
- (id)retain { return self; }
- (unsigned)retainCount { return UINT_MAX; }
- (void)release { }

- (void)dealloc {
	[viewInfoByHash release];
	[super dealloc];
}


@end


/////////////////////////////////////////////////////////////////////////////////////////////////

@implementation UIBlocker
@synthesize views;
@synthesize indicator;
@synthesize blockInteraction;

#pragma mark lifecycle


+ (UIBlocker*)blocker {
	return [[self new] autorelease];
}


+ (UIBlocker*)blockerForView:(UIView*)view {
	UIBlocker *blocker = [self blocker];	
	blocker.views = view ? [NSArray arrayWithObject:view] : nil;
	return blocker;
}


- (void)dealloc {
	[views release];
	[indicator release];
    [myIndicator release];
	[super dealloc];
}

#pragma mark publc

-(void)dontShowIndicator{
	dontShowIndicator = YES;
}

#pragma mark properties

- (void) setIndicator:(UIActivityIndicatorView*)_indicator{
    [_indicator retain];
    [indicator release];
    indicator = _indicator;
	
	dontShowIndicator = (_indicator == nil);
}
 
            

#pragma mark UIBlockingView

- (void)blockUI {

	for (UIView *view in views) {
		[[InteractionsBlockingService sharedService] blockView:view];
	}

    if (blockInteraction) {
        [[InteractionsBlockingService sharedService] blockGlobalInteractions];
    }
}


- (void)unblockUI {
	for (UIView *view in views) {
		[[InteractionsBlockingService sharedService] unblockView:view];
	}
	
	[indicator stopAnimating];
    [myIndicator stopAnimating];
    [myIndicator removeFromSuperview];

    if (blockInteraction) {
        [[InteractionsBlockingService sharedService] unblockGlobalInteractions];
    }
}


- (void)showIndicator {
    UIActivityIndicatorView *activeIndicator = self.indicator;
    if (!(activeIndicator || dontShowIndicator)) {
        if (!myIndicator) {
            myIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle: UIActivityIndicatorViewStyleWhiteLarge];
            myIndicator.hidesWhenStopped = YES;
        }		
					 
        UIWindow *window = [UIApplication sharedApplication].keyWindow;
		UIView* v = (views && views.count == 1) ? [views objectAtIndex:0] : window;
        [v addSubview:myIndicator];
        myIndicator.center = CGRectCenter(v.bounds);
        activeIndicator = myIndicator;
    }
	activeIndicator.hidden = NO;
	[activeIndicator startAnimating];
}

@end