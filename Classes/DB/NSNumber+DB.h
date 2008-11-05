#import <UIKit/UIKit.h>
#import <sqlite3.h>
#import "DBSession.h"

@interface NSNumber(DB)

- (void)bindToParam:(NSUInteger)i inStatement:(sqlite3_stmt*)stmt session:(DBSession*)session;

@end
