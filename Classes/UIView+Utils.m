#import "UIView+Utils.h"

@implementation UIView(utils)

- (NSMutableString*)addHierarchyTo:(NSMutableString*)hierarchyString prefix:(NSString*)prefix {
	[hierarchyString appendFormat:@"%@%@ [%d]\n", prefix, self, self.tag];
	
	for(UIView *v in self.subviews){
		[v addHierarchyTo:hierarchyString prefix:[prefix stringByAppendingString:@"  "]];
	}
	
	return hierarchyString;
}


- (NSString*)hierarchyString {
	return [[[self addHierarchyTo:[NSMutableString string] prefix: @""] copy] autorelease];
}


- (void)dumpHierarchy {
    NSLog(@"\n%@", [self hierarchyString]);
}


@end