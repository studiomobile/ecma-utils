#import <UIKit/UIKit.h>

@interface UIViewController(NIB)
- (void)replacePlaceholderViewFromOwnNib: (UIView*)v;
- (void)replacePlaceholderView:(UIView*)v fromNibNamed:(NSString*)name;
@end