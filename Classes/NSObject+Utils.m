#import "NSObject+Utils.h"

void checkNotNil(id value, NSString *message) {
	if(value == nil) {
		[NSException raise:@"ArgumentNullException" format:@"%@", message];
	}
}

void checkNotNull(void *value, NSString *message) {
	if(value == NULL) {
		[NSException raise:@"ArgumentNullException" format:@"%@", message];
	}}

void checkState(BOOL result, NSString *message) {
	if(!result) {
		[NSException raise:@"InvalidStateException" format:@"%@", message];
	}
}

void checkArgument(BOOL result, NSString *message) {
	if(!result) {
		[NSException raise:@"ArgumentException" format:@"%@", message];
	}
}


@implementation NSObject(ArgChecking)

+ (void)notNull:(id)value message:(NSString *)message {
	checkNotNil(value, message);
}


+ (void)state:(BOOL)result message:(NSString*)message {
	checkState(result, message);
}


+ (void)argument:(BOOL)result message:(NSString*)message {
	checkArgument(result, message);
}
@end


@implementation NSObject (Utils)

-(NSArray*) arrayed{
	return [NSArray arrayWithObject: self];
}

@end
