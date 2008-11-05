#import "NSString+DB.h"


@implementation NSString(DB)

- (void)bindToParam:(NSUInteger)i inStatement:(sqlite3_stmt*)stmt session:(DBSession*)session {
	const char *cstr = [self UTF8String];
	sqlite3_bind_text(stmt, i, cstr, strlen(cstr), SQLITE_STATIC);
}

- (int)test {
	return 20;
}

@end
