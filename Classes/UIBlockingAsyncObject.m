#import "UIBlockingAsyncObject.h"
#import "UIApplication+Utils.h"
#import "NSObject+Utils.h"


@interface UnblockUIOp : NSOperation {
    NSOperationQueue *mainQueue;
    NSArray *views;
    UIActivityIndicatorView *indicator;
    BOOL finished;
}

- (id)initWithViews:(NSArray*)v andActivityIndicator:(UIActivityIndicatorView*)ind andMainQueue:(NSOperationQueue*)queue;
@end


@implementation UnblockUIOp

- (id)initWithViews:(NSArray*)v andActivityIndicator:(UIActivityIndicatorView*)ind andMainQueue:(NSOperationQueue*)queue {
    checkNotNil(queue, @"Queue cannot be null");
    if (self = [super init]) {
        views = [v retain];
        if (views) {
            for(UIView *v in views) {
                v.userInteractionEnabled = NO;
            }
        } else {
            [[UIApplication sharedApplication] beginIgnoringInteractionEvents];
        }
        indicator = [ind retain];
        finished = FALSE;
        NSTimer *timer = [NSTimer timerWithTimeInterval:0.5 target:self selector:@selector(indicatorTimer:) userInfo:nil repeats:NO];
        [[NSRunLoop currentRunLoop] addTimer:timer forMode:NSDefaultRunLoopMode];
        mainQueue = [queue retain];
    }
    return self;
}

- (void)indicatorTimer:(NSTimer *)timer {
    //since enableUserInteractions invoked in main thread this method and enableUserInteractions cannot 
    //execute concurrently. So we can access this flag without synchronization
	
    if(!finished) {
        [indicator startAnimating];
    }
}

- (void)main {
    [mainQueue waitUntilAllOperationsAreFinished];
    [self performSelectorOnMainThread:@selector(enableUserInteractions) withObject:nil waitUntilDone:YES];
}

- (void)enableUserInteractions {
    if (views) {
        for(UIView *v in views) {
            v.userInteractionEnabled = YES;
	}
    } else {
        [[UIApplication sharedApplication] endIgnoringInteractionEvents];
    }
    finished = TRUE;
    [indicator stopAnimating];
}

- (void)dealloc {
    [mainQueue release];
    [views release];
    [indicator release];
    [super dealloc];
}

@end


@implementation UIBlockingAsyncObject

- (id)initWithImpl:(id)impl{
    if(self = [super initWithImpl:impl]) {
        uiUnblockQueue = [[NSOperationQueue alloc] init];
    }
    return self;
}

- (void)dealloc {
    [uiUnblockQueue release];
    [super dealloc];
}


- (id)ifSuccess:(SEL)successSelector ifError:(SEL)errorSelector target:(id)target blockView:(UIView*)v {
	return [self ifSuccess:successSelector ifError:errorSelector target:target blockViews:[NSArray arrayWithObjects:v, nil]];
}

- (id)ifSuccess:(SEL)successSelector ifError:(SEL)errorSelector target:(id)target blockViews:(NSArray*)v {
	views = [v retain];
	return [super ifSuccess:successSelector ifError:errorSelector target:target];
}

- (id)ifSuccess:(SEL)successSelector ifError:(SEL)errorSelector target:(id)target blockView:(UIView*)v andDisplayIndicator:(UIActivityIndicatorView*)i {
	return [self ifSuccess:successSelector ifError:errorSelector target:target blockViews:[NSArray arrayWithObjects:v, nil] andDisplayIndicator:i];
}

- (id)ifSuccess:(SEL)successSelector ifError:(SEL)errorSelector target:(id)target displayIndicator:(UIActivityIndicatorView*)i {
    return [self ifSuccess:successSelector ifError:errorSelector target:target blockViews:[NSArray array] andDisplayIndicator:i];
}

- (id)ifSuccess:(SEL)successSelector ifError:(SEL)errorSelector target:(id)target blockViews:(NSArray*)v andDisplayIndicator:(UIActivityIndicatorView*)i {
	views = [v retain];
	indicator = [i retain];
	return [super ifSuccess:successSelector ifError:errorSelector target:target];
}

- (void)forwardInvocation:(NSInvocation*)anInvocation {
    [super forwardInvocation:anInvocation];
    UnblockUIOp *unblockUI = [[[UnblockUIOp alloc] initWithViews:views andActivityIndicator:indicator andMainQueue:queue] autorelease];
    [views release];
    [indicator release];
    views = nil;
    indicator = nil;
    [uiUnblockQueue addOperation:unblockUI];
}

@end
