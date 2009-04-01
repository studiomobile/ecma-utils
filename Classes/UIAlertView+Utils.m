#import "UIAlertView+Utils.h"

@interface ModalAlertViewer : NSObject<UIAlertViewDelegate>
{
	BOOL exitLoop;
}

@end

@implementation ModalAlertViewer

-(void)showModal: (UIAlertView*)alert{	
	alert.delegate = self;
	[alert show];
	
	while (!exitLoop)
		[[NSRunLoop mainRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.1]];
}

+(void)showModal: (UIAlertView*)alert{
	ModalAlertViewer* inst = [[ModalAlertViewer new]autorelease];
	[inst showModal: alert];
}

#pragma mark UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
	exitLoop = YES;
}

@end

/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

@implementation UIAlertView (Utils)

+(UIAlertView*)createAlertViewWithTitle: (NSString*)title message: (NSString*)message{
	UIAlertView* alert = [[UIAlertView alloc]initWithTitle:title message:message delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
	return alert;
}

+(void)showAlertViewWithTitle: (NSString*)title message: (NSString*)message{
	[[[self createAlertViewWithTitle: title message: message]autorelease]show];
}


+(void)showAlertViewWithMessage: (NSString*)message{
	[self showAlertViewWithTitle:nil message:message];
}


+(void)showModalAlertViewWithTitle: (NSString*)title message: (NSString*)message{	
	UIAlertView* alert = [[self createAlertViewWithTitle:title message:message]autorelease];	
	[ModalAlertViewer showModal: alert];	
}

+(void)showModalAlertViewWithMessage: (NSString*)message{	
	[self showModalAlertViewWithTitle:nil message:message];
}

@end
