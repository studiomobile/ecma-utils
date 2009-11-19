#import "UIView+NIB.h"

@implementation UIView (NIB)

+ (NSString*)nibName {
    return [self description];
}


+ (id)loadFromNIB {
    Class klass = [self class];
    NSString *nibName = [self nibName];
    
    NSArray* objects = [[NSBundle mainBundle] loadNibNamed:nibName owner:self options:nil];
    
    for (id object in objects) {
        if ([object isKindOfClass:klass]) {
            return object;
        }
    }
    
    [NSException raise:@"WrongNibFormat" format:@"Nib for '%@' must contain one UIView, and its class must be '%@'", nibName, NSStringFromClass(klass)];	
    
    return nil;
}


@end
