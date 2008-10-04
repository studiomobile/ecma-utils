#import "UIApplication+AppAdditions.h"

@implementation UIApplication(AppAdditions)

+ (UINavigationController*) navigationController {
	id d = [[UIApplication sharedApplication] delegate];
	return [d navigationController];
}

+ (AsyncObject*)service {
	id d = [[UIApplication sharedApplication] delegate];
	return [d service];
}


@end
