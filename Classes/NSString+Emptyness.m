#import "NSString+Emptyness.h"

@implementation NSString(Emptyness)

- (BOOL)isEmpty {
	return [[self stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"\n\r\t "]] isEqualToString:@""];
}

- (BOOL)isNotEmpty {
	return ![self isEmpty];
}

@end
