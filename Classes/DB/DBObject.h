#import <UIKit/UIKit.h>
#import "DBSession.h"
#import "SelfDescribing.h"

@interface DBObject : SelfDescribing {
	long long pk;
	DBSession *session;
}

- (id)initWithSession:(DBSession*)s;

- (void)save;
- (void)remove;
- (BOOL)saved;

- (void)bindToParam:(NSUInteger)i inStatement:(sqlite3_stmt*)statement session:(DBSession*)session;

- (void)detachFromSession;
- (void)attachToSession:(DBSession*)session;
@property (readwrite, nonatomic) long long pk;

@end
