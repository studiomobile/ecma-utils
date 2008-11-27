#import <sqlite3.h>
#import <UIKit/UIKit.h>

#import "SelfDescribing.h"

#define DBOBJECT_NO_ID -1

@interface DBObject : SelfDescribing {
	long long pk;
}

+ (NSString*)tableName;
+ (NSString*)pkColumn;

- (NSString*)tableName;
// this column will be mapped to pk property, default is @"pk"
- (NSString*)pkColumn;

- (void)afterLoad;
- (BOOL)saved;

- (void)bindToParam:(NSUInteger)i inStatement:(sqlite3_stmt*)statement;


@property (readwrite, nonatomic) long long pk;

@end
