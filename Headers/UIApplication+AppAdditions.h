#import <UIKit/UIKit.h>
#import "AsyncObject.h"

@interface UIApplication(AppAdditions)
+ (UINavigationController*) navigationController;
+ (AsyncObject*) service;
@end
