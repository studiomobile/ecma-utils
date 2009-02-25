#import "ForwardingLabel.h"


@implementation ForwardingLabel

@synthesize forwardee;

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
	[super touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event];
	[forwardee becomeFirstResponder];
}

- (id)initWithFrame:(CGRect)frame{
	if(![super initWithFrame:frame])
		return nil;
	
	self.userInteractionEnabled = YES;	
	return self;	
}

-(void)dealloc{
	[forwardee release];
	[super dealloc];
}

@end
