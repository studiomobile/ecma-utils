#import <UIKit/UIKit.h>
#import <sqlite3.h>

@class DBObject;
@class DB;

@interface DBSession : NSObject {
	DB* db;
	sqlite3 *impl;
	NSMutableDictionary *identityMaps;
}

- (id)initWithDB:(DB*)database;

- (NSArray*)select:(Class)klass conditions:(NSString*)criteria, ...;
- (id)select:(Class)klass wherePk:(long long)pk;
- (NSArray*)selectOne:(Class)klass conditions:(NSString*)criteria, ...;
- (sqlite3_stmt*)prepareStmt:(NSString*)sql arguments:(id)arg1, ...;

- (long long)executeNumber:(NSString *)query, ...;

- (void)save:(DBObject*)o;
- (void)delete:(Class)klass where:(NSString*)criteria, ...;

- (void)removeFromIdentityMap:(DBObject*)o;

@end
