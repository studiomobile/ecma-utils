#import <Foundation/Foundation.h>

@protocol UIBlockingView <NSObject>
- (void)blockUI;
- (void)unblockUI;
- (void)showIndicator;
@end
