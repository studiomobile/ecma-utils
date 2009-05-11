#import <sqlite3.h>
#import <UIKit/UIKit.h>

#import "SelfDescribing.h"

#define DBOBJECT_NO_ID -1

@interface DBObject : SelfDescribing {
	long long pk;
}
@property (readwrite, nonatomic) long long pk;
@property (readonly) BOOL isNewRecord;

+ (NSString*)tableName;
+ (NSString*)pkColumn;

- (NSString*)tableName;
// this column will be mapped to pk property, default is @"pk"
- (NSString*)pkColumn;

- (void)afterLoad;
- (void)beforeSave;
- (void)beforeInsert;
- (void)beforeUpdate;
- (void)afterInsert;
- (void)afterUpdate;
- (void)afterSave;

- (void)bindToParam:(NSUInteger)i inStatement:(sqlite3_stmt*)statement;


@end
