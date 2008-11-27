#import "NSNumber+DB.h"

@implementation NSNumber(DB)

- (void)bindToParam:(NSUInteger)i inStatement:(sqlite3_stmt*)statement {
	const char *type = [self objCType];
	if(strcmp(type, @encode(int)) == 0 || 
	   strcmp(type, @encode(char)) == 0 || 
	   strcmp(type, @encode(long)) == 0 || 
	   strcmp(type, @encode(long long)) == 0 ||
	   strcmp(type, @encode(unsigned int)) == 0 ||
	   strcmp(type, @encode(unsigned long)) == 0 ||
	   strcmp(type, @encode(unsigned long long)) == 0) {
		sqlite3_bind_int64(statement, i, [self longLongValue]);
	} else if(strcmp(type, @encode(double)) == 0 || strcmp(type, @encode(float)) == 0) {
		sqlite3_bind_double(statement, i, [self doubleValue]);
	} else {
		NSLog(@"NSNumber: Failed to bind parameter");
	}
}

@end
