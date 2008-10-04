#import "NSObject+ArgChecking.h"


@implementation NSObject(ArgChecking)
+ (void)notNull:(id)value message:(NSString *)format, ... {
	if(value == NULL || value == nil) {
		va_list argList;
		[NSException raise:@"ArgumentNullException" format:format arguments:argList];
	}
}


+ (void)state:(BOOL)result message:(NSString*)format, ... {
	if(!result) {
		va_list argList;
		[NSException raise:@"InvalidStateException" format:format arguments:argList];
	}
}


+ (void)argument:(BOOL)result message:(NSString*)format, ... {
	if(!result) {
		va_list argList;
		[NSException raise:@"ArgumentException" format:format arguments:argList];
	}
}
@end
