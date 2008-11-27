#import "DBSession.h"
#import "DB.h"
#import "DBObject.h"
#import "NSObject+Utils.h"
#import <objc/runtime.h>
#import "NSError+Utils.h"

static id va_listIterator(void *list, int idx) {
	va_list *lst = (va_list*)list;
	return va_arg(*lst, id);
}

static id arrayIterator(void *list, int idx) {
	id *a = (id*)list;
	return a[idx];
}

@implementation DBSession

- (id)initWithDB:(DB*)database {
	checkNotNull(database, @"Database cannot be null");
	if (self = [super init]) {
		db = database;
		impl = [db impl];
		identityMaps = [[NSMutableDictionary alloc] init];
	}
	return self;
}

- (void)dealloc {
	for(NSMutableDictionary *identityMap in [identityMaps allValues]) {
		for(DBObject *obj in [identityMap allValues]) {
			[obj detachFromSession];
		}
	}
	[identityMaps release];
	[super dealloc];
}

- (NSMutableDictionary *)tableIdentityMap:(NSString *)key  {
	NSMutableDictionary *identityMap = [identityMaps objectForKey:key];
	if(identityMap == nil) {
		identityMap = [[NSMutableDictionary alloc] init];
		[identityMaps setObject:identityMap forKey:key];
		[identityMap release];
	}
	return identityMap;
}


- (id)mapObjectOfClass:(Class)klass table:(NSString*)key to:(sqlite3_stmt*)stmt{
	NSMutableDictionary *identityMap = [self tableIdentityMap: key];
	DBObject *obj = nil;
	for (int i = 0; i <  sqlite3_column_count(stmt); i++) {
		NSString *colName = [NSString stringWithUTF8String:sqlite3_column_name(stmt, i)];
		if([colName isEqualToString:[klass pkColumn]]) {
			NSNumber *pk = [NSNumber numberWithLongLong:sqlite3_column_int64(stmt, i)];
			obj = [identityMap objectForKey:pk];
			if(obj != nil) {
				return obj;
			}
		}
	}
	obj = (DBObject*)[[klass alloc] initWithSession:self];//!! check that klass is actually subclass of DBObject
	for (int i = 0; i <  sqlite3_column_count(stmt); ++i) {
		NSString *colName = [NSString stringWithUTF8String:sqlite3_column_name(stmt, i)];
		int type = sqlite3_column_type(stmt, i);
		switch(type) {
			case SQLITE_INTEGER: {
				long long val = sqlite3_column_int64(stmt, i);
				[obj setValue:[NSNumber numberWithLongLong:val] forKey:colName];
				break;
			}
			case SQLITE_FLOAT: {
				double val = sqlite3_column_double(stmt, i);
				[obj setValue:[NSNumber numberWithDouble:val] forKey:colName];
				break;
			}
			case SQLITE_TEXT: {
				const unsigned char *txt = sqlite3_column_text(stmt, i);
				[obj setValue:[NSString stringWithUTF8String:(const char*)txt] forKey:colName];
				break;
			}
			case SQLITE_NULL:{
				[obj setValue:nil forKey:colName];
				break;
			}
			case SQLITE_BLOB:{
				LOG1(@"Blobs unsupported");
				break;
			}
		}
	}
	
	[obj afterLoad];
	
	[identityMap setObject:obj forKey:[NSNumber numberWithLongLong:obj.pk]];
	[obj release];
	return obj;
}

//- (NSString*)tableName:(Class)klass {
//	if([klass respondsToSelector:@selector(tableName)]) {
//		return [klass performSelector:@selector(tableName)];
//	}
//	
//	return @"";
//}
//
- (void)removeFromIdentityMap:(DBObject*)o {
	checkNotNull(o, @"Object cannot be null");
	NSMutableDictionary *identityMap = [identityMaps objectForKey:[o tableName]];
	[identityMap removeObjectForKey:[NSNumber numberWithLongLong:o.pk]];
}


- (NSArray*)tableColumns:(Class)klass {
	NSString *tableName = [klass tableName];

	NSMutableArray *columns = [NSMutableArray array];
	const char *sql = [[NSString stringWithFormat:@"pragma table_info(%@)", tableName] UTF8String];
	sqlite3_stmt *stmt;
	if(sqlite3_prepare_v2(impl, sql, -1, &stmt, NULL) == SQLITE_OK) {
		while (sqlite3_step(stmt) == SQLITE_ROW) {
			const unsigned char *ccolName = sqlite3_column_text(stmt, 1);
			NSString *colName = [NSString stringWithUTF8String:(const char*)ccolName];
			if([colName isEqualToString:[klass pkColumn]]) {
				continue;
			} else {
				[columns addObject:colName];
			}
		}
		sqlite3_finalize(stmt);
	} else {
		const char *error = sqlite3_errmsg(impl);
		checkState(FALSE, [NSString stringWithFormat:@"SQLite error: %s", error]);
	}
	return columns;
}


- (sqlite3_stmt*)prepareStmt:(NSString*)sql params:(void*)stmtParams nextArg:(id(*)(void *list, int idx))nextArgumentCallback {
	sqlite3_stmt *statement;
	LOG2(@"Preparing SQL:%@", sql);
	int r = sqlite3_prepare_v2(impl, [sql UTF8String], -1, &statement, NULL);
	if (r == SQLITE_OK) {
		int paramCount = sqlite3_bind_parameter_count(statement);
		for(int i = 0 ; i < paramCount; ++i) {
			id param = nextArgumentCallback(stmtParams, i);
			[param bindToParam:i + 1 inStatement:statement session:self];
		}
		return statement;
	} else {
		const char *error = sqlite3_errmsg(impl);
		checkArgument(FALSE, [NSString stringWithFormat:@"SQLite error: %s", error]);
	}
	return NULL;
}


- (void)update:(DBObject*)o {
	NSString *tableName = [o tableName];
	NSArray *columns = [self tableColumns:[o class]];
	id *args = malloc(sizeof(id)*([columns count] + 1));
	NSMutableString *updateQuery = [NSMutableString string];
	[updateQuery appendFormat:@"update %@ set ", tableName];
	for(int i = 0; i < [columns count] - 1; ++i) {
		NSString *propName = [columns objectAtIndex:i];
		[updateQuery appendFormat:@"%@ = ?,", propName];
		args[i] = [o valueForKey:propName];
	}
	[updateQuery appendFormat:@"%@ = ? where %@ = ?", [columns lastObject], [o pkColumn]];
	args[[columns count] - 1] = [o valueForKey:[columns lastObject]];
	args[[columns count]] = [NSNumber numberWithLongLong:o.pk];
	
	sqlite3_stmt *stmt = [self prepareStmt:updateQuery params:args nextArg:&arrayIterator];
	id param = [NSNumber numberWithLongLong:o.pk];
	[param bindToParam:[columns count] + 1 inStatement:stmt session:self];
	int stepResult = sqlite3_step(stmt);
	LOG2(@"Update result: %d", stepResult);
	sqlite3_finalize(stmt);
	free(args);
}


- (void)insert:(DBObject*)o {
	NSString *tableName = [o tableName];
	NSArray *columns = [self tableColumns:[o class]];	
	NSMutableString *insertQuery = [NSMutableString string];
	id *args = malloc(sizeof(id)*[columns count]);
	[insertQuery appendFormat:@"insert into %@ (", tableName];
	for(int i = 0; i < [columns count] - 1; ++i) {
		NSString *propName = [columns objectAtIndex:i];
		[insertQuery appendFormat:@"%@,", propName];
		args[i] = [o valueForKey:propName];
	}
	[insertQuery appendFormat:@"%@) values (", [columns lastObject]];
	args[[columns count] - 1] = [o valueForKey:[columns lastObject]];
	for(int i = 0; i < [columns count] - 1; ++i) {
		[insertQuery appendString:@"?,"];
	}
	[insertQuery appendString:@"?)"];
	
	sqlite3_stmt *stmt = [self prepareStmt:insertQuery params:args nextArg:&arrayIterator];
	int stepResult = sqlite3_step(stmt);
	LOG2(@"Insert sql returned:%d", stepResult);
	sqlite3_finalize(stmt);
	o.pk = [self executeNumber:@"select last_insert_rowid()"];
	NSMutableDictionary *identityMap = [self tableIdentityMap: tableName];
	NSNumber *pkNumber = [NSNumber numberWithLongLong:o.pk];
	checkState([identityMap objectForKey:pkNumber] == nil, @"identity map already contain just inserted object");
	[identityMap setObject:o forKey:pkNumber];
	free(args);
}

- (void)save:(DBObject*)o {
	if([o saved]) {
		[self update:o];
	} else {
		[self insert:o];
	}
}

- (sqlite3_stmt*)prepareStmt:(NSString*)sql arguments:(id)arg1, ... {
	checkNotNil(sql, @"sql cannot be nil");
	va_list stmtParams;
	va_start(stmtParams, arg1);
	sqlite3_stmt *stmt = [self prepareStmt:sql params:&stmtParams nextArg:&va_listIterator];
	va_end(stmtParams);
	return stmt;
}

- (NSArray*)select:(Class)klass conditions:(NSString*)criteria params:(va_list)stmtParams {
	checkNotNil(criteria, @"Criteria cannot be nil");
	checkNotNil(klass, @"klass cannot be nil");
	
	NSString *tableName = [klass tableName];
	NSString *sql = [NSString stringWithFormat:@"select * from %@ %@", tableName, criteria];
	sqlite3_stmt *statement = [self prepareStmt:sql params:&stmtParams nextArg:&va_listIterator];
	NSMutableArray *result = [NSMutableArray array];
	while (sqlite3_step(statement) == SQLITE_ROW) {
		id obj = [self mapObjectOfClass:klass table:tableName to:statement];
		if(obj != nil) {
			[result addObject:obj];
		}
	}
	sqlite3_finalize(statement);
	return result;
}

- (NSArray*)select:(Class)klass conditions:(NSString*)criteria, ... {
	va_list stmtParams;
	va_start(stmtParams, criteria);
	NSArray *result = [self select:klass conditions:criteria params:stmtParams];
	va_end(stmtParams);
	return result;
}

- (NSArray*)selectOne:(Class)klass conditions:(NSString*)criteria, ... {
	va_list stmtParams;
	va_start(stmtParams, criteria);
	NSArray *result = [self select:klass conditions:criteria params:stmtParams];
	va_end(stmtParams);
	if([result count] > 0) {
		return [result objectAtIndex:0];
	} else {
		return nil;
	}
}

- (id)select:(Class)klass wherePk:(long long)pk {
	NSArray *result = [self select:klass conditions:[NSString stringWithFormat:@"WHERE %@ = ?", [klass pkColumn]], [NSNumber numberWithLongLong:pk]];
	if([result count] == 1) {
		return [result objectAtIndex:0];
	} else {
		return nil;
	}
}

- (void)delete:(Class)klass where:(NSString*)criteria, ... {
	checkNotNil(criteria, @"Criteria cannot be nil");
	checkNotNil(klass, @"klass cannot be nil");
	
	va_list stmtParams;
	va_start(stmtParams, criteria);
	NSString *sql = [NSString stringWithFormat:@"delete from %@ %@", [klass tableName], criteria];
	sqlite3_stmt *stmt = [self prepareStmt:sql params:&stmtParams nextArg:&va_listIterator];
	while(sqlite3_step(stmt) == SQLITE_ROW);
	sqlite3_finalize(stmt);
	va_end(stmtParams);
}

- (long long)executeNumber:(NSString *)query, ... {
	va_list stmtParams;
	va_start(stmtParams, query);
	
	sqlite3_stmt *statement = [self prepareStmt:query params:&stmtParams nextArg:&va_listIterator];
	long long result = 0;
	while (sqlite3_step(statement) == SQLITE_ROW) {
		result = sqlite3_column_int64(statement, 0);
	}
	sqlite3_finalize(statement);
	va_end(stmtParams);
	return result;
}

@end
