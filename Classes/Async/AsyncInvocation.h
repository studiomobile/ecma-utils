#import <Foundation/Foundation.h>

@protocol AsyncInvocation<NSObject>
	-(void)cancel;
@end