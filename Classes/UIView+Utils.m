#import "UIView+Utils.h"

@implementation UIView(utils)

-(NSMutableString*)addHierarchyTo: (NSMutableString*)hierarchyString prefix:(NSString*)prefix{
	[hierarchyString appendFormat: @"%@%@ [%.0f %.0f %.0f %.0f]\n", prefix, self, 
	 self.frame.origin.x, 
	 self.frame.origin.y, 
	 self.frame.size.width, 
	 self.frame.size.height];
	
	for(UIView* v in self.subviews){
		[v addHierarchyTo: hierarchyString prefix: [prefix stringByAppendingString:@"  "]];
	}
	
	return hierarchyString;
}

-(NSString*) hierarchyString{
	return [[[self addHierarchyTo: [NSMutableString string] prefix: @""] copy] autorelease];
}

@end