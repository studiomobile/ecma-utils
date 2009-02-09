#import "NSUserDefaults+Utils.h"


@implementation NSUserDefaults(Utils)

+ (NSMutableArray*)loadArray:(NSString*)key {
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	NSData *data = [defaults objectForKey:key];
	if (data.length > 0) {
		return [NSKeyedUnarchiver unarchiveObjectWithData:data];
	} else {
		return [NSMutableArray array];
	}
}

+ (void)saveArray:(NSMutableArray*)array forKey:(NSString*)key {
	NSData *data = [NSKeyedArchiver archivedDataWithRootObject:array];
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	[defaults setObject:data forKey:key];
}

@end


@implementation NSObject(NSUserDefaults)

- (void)initDefaults {
    [self initDefaults:[NSUserDefaults standardUserDefaults]];
}

- (void)initDefaults:(NSUserDefaults*)defaults {
    NSString *key = NSStringFromClass([self class]);
    BOOL alreadyInited = [defaults boolForKey:key];
    if (!alreadyInited && [self respondsToSelector:@selector(doInitUserDefaults:)]) {
        [self performSelector:@selector(doInitUserDefaults:) withObject:defaults];
        [defaults setBool:YES forKey:key];
    }
}

@end
