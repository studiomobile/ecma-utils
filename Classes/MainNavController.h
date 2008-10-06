#import <UIKit/UIKit.h>
#import "TradeonlyWebService.h"
#import "AsyncObject.h"

@interface UIApplication(MainNavController)

+ (UINavigationController*) navigationController;
+ (AsyncObject*) ws;

@end
