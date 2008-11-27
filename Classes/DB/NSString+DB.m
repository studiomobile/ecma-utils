#import "NSString+DB.h"


@implementation NSString(DB)

- (void)bindToParam:(NSUInteger)i inStatement:(sqlite3_stmt*)stmt {
	const char *cstr = [self UTF8String];
	sqlite3_bind_text(stmt, i, cstr, strlen(cstr), SQLITE_STATIC);
}

@end
