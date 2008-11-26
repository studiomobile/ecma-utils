#import <UIKit/UIKit.h>
#import "DBSession.h"
#import "SelfDescribing.h"

@interface DBObject : SelfDescribing {
	long long pk;
	DBSession *session;
}

+ (NSString*)tableName;
+ (NSString*)pkColumn;

- (id)initWithSession:(DBSession*)s;

- (NSString*)tableName;
- (NSString*)pkColumn;

- (void)save;
- (void)remove;
- (BOOL)saved;

- (void)bindToParam:(NSUInteger)i inStatement:(sqlite3_stmt*)statement session:(DBSession*)session;

- (void)detachFromSession;
- (void)attachToSession:(DBSession*)session;
@property (readwrite, nonatomic) long long pk;

@end
