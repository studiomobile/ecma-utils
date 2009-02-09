#import <UIKit/UIKit.h>
#import <sqlite3.h>

@interface NSNumber(DB)

- (void)bindToParam:(NSUInteger)i inStatement:(sqlite3_stmt*)stmt;

@end
