#import <UIKit/UIKit.h>
#import <sqlite3.h>

#import "DBObject.h"

#define kDBErrorDomain @"DBErrorDomain"
extern const NSUInteger kFailedToOpenDB;

@interface DB : NSObject {
	NSString *dbName;
	sqlite3 *impl;
}

+ (DB*)createDB:(NSString*)dbName error:(NSError**)error;
+ (DB*)dbNamed:(NSString*)dbName;

- (id)initWithDBName:(NSString*)db error:(NSError**)error;

- (NSArray*)select:(Class)klass conditions:(NSString*)criteria, ...;
- (id)select:(Class)klass wherePk:(long long)pk;
- (NSArray*)selectOne:(Class)klass conditions:(NSString*)criteria, ...;

- (sqlite3_stmt*)prepareStmt:(NSString*)sql arguments:(id)arg1, ...;

- (long long)executeNumber:(NSString *)query, ...;

- (void)update:(DBObject*)o;
- (void)insert:(DBObject*)o;
- (void)save:(DBObject*)o; // insert or update based on pk value
- (void)delete:(Class)klass where:(NSString*)criteria, ...;

- (void)beginTransaction;
- (void)commit;
- (void)rollback;
@end
