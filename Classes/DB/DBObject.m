#import "DBObject.h"
#import <objc/runtime.h>
#import "NSObject+Utils.h"

@implementation DBObject

@synthesize pk;

+ (NSString*)tableName {
	return [NSString stringWithCString:class_getName([self class])];
}

- (NSString*)tableName {
	return [[self class] tableName];
}

+ (NSString*)pkColumn {
	return @"pk";
}

- (NSString*)pkColumn {
	return [[self class] pkColumn];
}

+ (void)initMetadata {
	[self map:@selector(pk) to:[NSString class]];
}

- (id)init {
	if(self = [super init]) {
		pk = -1;
		session = nil;
	}
	return self;
}

- (id)initWithSession:(DBSession*)s {
	if (self = [self init]) {
		session = s;
	}
	return self;
}

- (void)detachFromSession {
	session = nil;
}

- (void)attachToSession:(DBSession*)sess {
	checkNotNil(sess, @"sess is nil");
	checkState(session == nil || session == sess, @"cannot attach to session if object already atatched to another session");
	session = sess;
}

- (BOOL)saved {
	return pk != -1;
}

- (void)remove {
	[session delete:[self class] where:[NSString stringWithFormat:@"where %@ = ?", [self pkColumn]], [NSNumber numberWithLongLong:self.pk]];
}

- (void)save {
	[session save:self];
}

- (void)bindToParam:(NSUInteger)i inStatement:(sqlite3_stmt*)statement session:(DBSession*)session {
	sqlite3_bind_int64(statement, i, self.pk);
}

@end
