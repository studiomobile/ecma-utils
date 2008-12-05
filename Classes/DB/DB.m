#import "DB.h"
#import "NSObject+Utils.h"
#import "NSNumber+DB.h"
#import "NSString+DB.h"
#import "DBObject.h"
#import "NSError+Utils.h"

#import <objc/runtime.h>

static id va_listIterator(void *list, int idx) {
	va_list *lst = (va_list*)list;
	return va_arg(*lst, id);
}

static id arrayIterator(void *list, int idx) {
	id *a = (id*)list;
	return a[idx];
}


const NSUInteger kFailedToOpenDB = 1;
static NSMutableDictionary *databases = nil;

@implementation DB

-(NSString*)checkAndCreateDatabase:(NSError**)error{
	NSFileManager *fileManager = [NSFileManager defaultManager];
	NSArray *documentPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentsDir = [documentPaths objectAtIndex:0];
	NSString *databasePath = [documentsDir stringByAppendingPathComponent:dbName];
	if([fileManager fileExistsAtPath:databasePath]){
		return databasePath;
	}
	NSString *dbPath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:dbName];
	[fileManager copyItemAtPath:dbPath toPath:databasePath error:error];
	[fileManager release];
	return databasePath;
}

- (id)initWithDBName:(NSString*)db error:(NSError**)error {
	if (self = [super init]) {
		dbName = [db copy];
		NSString *databasePath = [self checkAndCreateDatabase:error];
		if(sqlite3_open([databasePath UTF8String], &impl) != SQLITE_OK) {
			NSString *errorMsg = [NSString stringWithFormat: @"Failed to open database with message '%s'.", sqlite3_errmsg(impl)];
			NSDictionary *userInfo = [NSDictionary dictionaryWithObject:errorMsg forKey:NSLocalizedDescriptionKey];
			*error = [NSError errorWithDomain:kDBErrorDomain code:kFailedToOpenDB userInfo:userInfo]; 
			sqlite3_close(impl);
			impl = NULL;
		}
	}
	return self;
}

+ (DB*)dbNamed:(NSString*)dbName {
	return [databases objectForKey:dbName];
}

+ (DB*)createDB:(NSString*)dbName error:(NSError**)error {
	DB *database;
	@synchronized(databases) {
		if(databases == nil) {
			databases = [[NSMutableDictionary alloc] init];
		}
		database = [databases objectForKey:dbName];
		if(database == nil) {
			database = [[DB alloc] initWithDBName:dbName error:error];
			if(database != nil) {
				[databases setObject:database forKey:dbName];
				[database release];
			}
		}
	}
	return database;
}

- (void)dealloc {
	if(impl != NULL) {
		sqlite3_close(impl);		
	}
	[dbName release];
	[super dealloc];
}

- (id)createObjectOfClass:(Class)klass fromRow:(sqlite3_stmt*)stmt storedInTable:(NSString*)key {
	DBObject *obj = [[klass alloc] init];
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
				NSLog(@"Blobs unsupported");
				break;
			}
		}
	}
	
	[obj afterLoad];
	
	return obj;
}

- (NSArray*)tableColumns:(DBObject*)obj {
	NSMutableArray *columns = [NSMutableArray array];
	NSString *tableName = [obj tableName];
	const char *sql = [[NSString stringWithFormat:@"pragma table_info(%@)", tableName] UTF8String];
	sqlite3_stmt *stmt;
	if(sqlite3_prepare_v2(impl, sql, -1, &stmt, NULL) == SQLITE_OK) {
		while (sqlite3_step(stmt) == SQLITE_ROW) {
			const unsigned char *ccolName = sqlite3_column_text(stmt, 1);
			NSString *colName = [NSString stringWithUTF8String:(const char*)ccolName];
			if([colName isEqualToString:[obj pkColumn]]) {
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
			LOG2(@"SQL param: %@", param);
			[param bindToParam:i + 1 inStatement:statement];
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
	NSArray *columns = [self tableColumns:o];
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
	[param bindToParam:[columns count] + 1 inStatement:stmt];
	int stepResult = sqlite3_step(stmt);
	LOG2(@"Update result: %d", stepResult);
	sqlite3_finalize(stmt);
	free(args);
}


- (void)insert:(DBObject*)o {
	NSString *tableName = [o tableName];
	NSArray *columns = [self tableColumns:o];	
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
	free(args);
}

- (void)save:(DBObject*)o {
    [o beforeSave];

	if([o isNewRecord]) {
		[self insert:o];
	} else {
		[self update:o];
	}
	
	[o afterSave];
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
		id obj = [self createObjectOfClass:klass fromRow:statement storedInTable:tableName];
		if(obj != nil) {
			[result addObject:obj];
			[obj release];
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
	NSArray *result = [self select:klass conditions:[NSString stringWithFormat:@"%@ limit 1", criteria] params:stmtParams];
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
