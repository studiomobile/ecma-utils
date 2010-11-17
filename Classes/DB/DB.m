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

static id arrayAccessor(void *list, int idx) {
    id *a = (id*)list;
    return a[idx];
}

static id nsArrayAccessor(void *list, int idx) {
    NSArray *array = (NSArray*)list;
    return [array objectAtIndex:idx];
}

typedef id(*ArgAccessor)(void *list, int idx);

const NSUInteger kFailedToOpenDB = 1;
static NSMutableDictionary *databases = nil;


@interface DB ()

- (sqlite3_stmt*)prepareStmt:(NSString*)sql params:(void*)stmtParams argAccessor:(ArgAccessor)argumentAccessor;
- (id)createObjectOfClass:(Class)klass fromRow:(sqlite3_stmt*)stmt storedInTable:(NSString*)key;
- (NSArray*)tableColumns:(DBObject*)obj;

@end


@implementation DB

- (NSString*)checkAndCreateDatabase:(NSError**)error{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSArray *documentPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDir = [documentPaths objectAtIndex:0];
    NSString *databasePath = [documentsDir stringByAppendingPathComponent:dbName];
    if([fileManager fileExistsAtPath:databasePath]){
        return databasePath;
    }
    NSString *dbPath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:dbName];
    [fileManager copyItemAtPath:dbPath toPath:databasePath error:error];
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

//prepare statement methods
- (sqlite3_stmt*)prepareStmt:(NSString*)sql params:(void*)stmtParams argAccessor:(ArgAccessor)argumentAccessor {
    checkNotNil(sql, @"sql cannot be nil");
    sqlite3_stmt *statement;
    LOG2(@"Preparing SQL:%@", sql);
    int r = sqlite3_prepare_v2(impl, [sql UTF8String], -1, &statement, NULL);
    if (r == SQLITE_OK) {
        int paramCount = sqlite3_bind_parameter_count(statement);
        for(int i = 0 ; i < paramCount; ++i) {
            id param = argumentAccessor(stmtParams, i);
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


- (sqlite3_stmt*)prepareStmt:(NSString*)sql params:(NSArray*)params {
    return [self prepareStmt:sql params:params argAccessor:&nsArrayAccessor];
}

    
- (sqlite3_stmt*)prepareStmt:(NSString*)sql arguments:(id)arg1, ... {
    va_list stmtParams;
    va_start(stmtParams, arg1);
    sqlite3_stmt *stmt = [self prepareStmt:sql params:&stmtParams argAccessor:&va_listIterator];
    va_end(stmtParams);
    return stmt;
}


//select methods
- (NSArray*)select:(Class)klass
        conditions:(NSString*)criteria
            params:(void*)stmtParams
           argAccessor:(ArgAccessor)argumentAccessor {
    checkNotNil(criteria, @"Criteria cannot be nil");
    checkNotNil(klass, @"klass cannot be nil");
	
    NSString *tableName = [klass tableName];
    NSString *sql = [NSString stringWithFormat:@"select * from %@ %@", tableName, criteria];
    sqlite3_stmt *statement = [self prepareStmt:sql params:stmtParams argAccessor:argumentAccessor];
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


- (NSArray*)select:(Class)klass conditions:(NSString*)criteria params:(NSArray*)params {
    return [self select:klass conditions:criteria params:params argAccessor:&nsArrayAccessor];
}


- (NSArray*)select:(Class)klass conditions:(NSString*)criteria, ... {
    va_list stmtParams;
    va_start(stmtParams, criteria);
    NSArray *result = [self select:klass conditions:criteria params:&stmtParams argAccessor:&va_listIterator];
    va_end(stmtParams);
    return result;
}


- (id)select:(Class)klass wherePk:(long long)pk {
    NSString *where = [NSString stringWithFormat:@"WHERE %@ = ?", [klass pkColumn]];
    NSArray *result = [self select:klass conditions:where, [NSNumber numberWithLongLong:pk]];
    if([result count] == 1) {
        return [result objectAtIndex:0];
    } else {
        return nil;
    }
}


//select one methods
- (DBObject*)selectOne:(Class)klass
                offset:(NSInteger)offset
            conditions:(NSString*)criteria
                params:(void*)stmtParams
           argAccessor:(ArgAccessor)argumentAccessor{
    NSString *conditions = [NSString stringWithFormat:@"%@ limit 1 offset %d", criteria, offset];
    NSArray *result = [self select:klass conditions:conditions params:stmtParams argAccessor:argumentAccessor];
    if([result count] > 0) {
        return [result objectAtIndex:0];
    } else {
        return nil;
    }
}


- (DBObject*)selectOne:(Class)klass offset:(NSInteger)offset conditions:(NSString*)criteria, ... {
    va_list stmtParams;
    va_start(stmtParams, criteria);
    DBObject *result =[self selectOne:klass offset:offset conditions:criteria params:&stmtParams argAccessor:&va_listIterator];
    va_end(stmtParams);
    return result;
}


- (DBObject*)selectOne:(Class)klass offset:(NSInteger)offset conditions:(NSString*)criteria params:(NSArray*)params {
    return [self selectOne:klass offset:offset conditions:criteria params:params argAccessor:&nsArrayAccessor];
}


//save methods
- (void)save:(DBObject*)o {
    if([o isNewRecord]) {
        [self insert:o];
    } else {
        [self update:o];
    }
}


- (void)insert:(DBObject*)o {
    [o beforeSave];
    [o beforeInsert];
    NSString *tableName = [o tableName];
    NSMutableArray *columns = [NSMutableArray arrayWithArray:[self tableColumns:o]];	

    if(!o.isNewRecord) {
        [columns addObject:[o pkColumn]];
    }
    
    NSMutableString *insertQuery = [NSMutableString string];
    id *args = malloc(sizeof(id)*[columns count]);
    NSString *conflictClause = [o insertConflictClause];
    conflictClause = (conflictClause.length ? [@"" stringByAppendingString:conflictClause] : @"");
    [insertQuery appendFormat:@"insert%@ into %@ (", conflictClause, tableName];
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
	
    sqlite3_stmt *stmt = [self prepareStmt:insertQuery params:args argAccessor:&arrayAccessor];
    int stepResult = sqlite3_step(stmt);
    LOG2(@"Insert sql returned:%d", stepResult);
    sqlite3_finalize(stmt);
    o.pk = [self executeNumber:@"select last_insert_rowid()"];
    free(args);
 
    [o afterInsert];
    [o afterSave];
}


- (void)update:(DBObject*)o {
    [o beforeSave];
    [o beforeUpdate];
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
	
    sqlite3_stmt *stmt = [self prepareStmt:updateQuery params:args argAccessor:&arrayAccessor];
    id param = [NSNumber numberWithLongLong:o.pk];
    [param bindToParam:[columns count] + 1 inStatement:stmt];
    int stepResult = sqlite3_step(stmt);
    LOG2(@"Update result: %d", stepResult);
    sqlite3_finalize(stmt);
    free(args);
    [o afterUpdate];
    [o afterSave];
}

//delete methods
- (void)delete:(Class)klass
    conditions:(NSString*)criteria
        params:(void*)stmtParams
   argAccessor:(ArgAccessor)argumentAccessor {
    checkNotNil(criteria, @"Criteria cannot be nil");
    checkNotNil(klass, @"klass cannot be nil");
    NSString *sql = [NSString stringWithFormat:@"delete from %@ %@", [klass tableName], criteria];
    sqlite3_stmt *stmt = [self prepareStmt:sql params:stmtParams argAccessor:argumentAccessor];
    while(sqlite3_step(stmt) == SQLITE_ROW);
    sqlite3_finalize(stmt);
}


- (void)delete:(Class)klass conditions:(NSString*)criteria params:(NSArray*)params {
    [self delete:klass conditions:criteria params:params argAccessor:&nsArrayAccessor];
}


- (void)delete:(Class)klass conditions:(NSString*)criteria, ... {
    va_list stmtParams;
    va_start(stmtParams, criteria);
    [self delete:klass conditions:criteria params:&stmtParams argAccessor:&va_listIterator];
    va_end(stmtParams);
}

//execute number
- (long long)executeNumber:(NSString*)query
        params:(void*)stmtParams
   argAccessor:(ArgAccessor)argumentAccessor {
    sqlite3_stmt *statement = [self prepareStmt:query params:stmtParams argAccessor:argumentAccessor];
    long long result = 0;
    while (sqlite3_step(statement) == SQLITE_ROW) {
        result = sqlite3_column_int64(statement, 0);
    }
    sqlite3_finalize(statement);
    return result;
}


- (long long)executeNumber:(NSString *)query params:(NSArray*)params {
    return [self executeNumber:query params:params argAccessor:&nsArrayAccessor];
}


- (long long)executeNumber:(NSString *)query, ... {
    va_list stmtParams;
    va_start(stmtParams, query);
    long long result = [self executeNumber:query params:&stmtParams argAccessor:&va_listIterator];
    va_end(stmtParams);
    return result;
}


- (void)beginTransaction {
    [self executeNumber:@"begin transaction"];
}


- (void)commit {
    [self executeNumber:@"commit transaction"];
}


- (void)rollback {
    [self executeNumber:@"rollback transaction"];
}


- (void)loadObject:(DBObject*)obj fromRow:(sqlite3_stmt*)stmt storedInTable:(NSString*)key {
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
}

- (id)createObjectOfClass:(Class)klass fromRow:(sqlite3_stmt*)stmt storedInTable:(NSString*)key {
    DBObject *obj = [[klass alloc] init];
	
    [self loadObject:obj fromRow:stmt storedInTable:key];
    
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


- (void)reload:(DBObject*)o {
    NSString *tableName = [o tableName];
    NSString *sql = [NSString stringWithFormat:@"select * from %@ where %@ = ?", tableName, [o pkColumn]];
    sqlite3_stmt *statement = [self prepareStmt:sql arguments:sql, [NSNumber numberWithLongLong:o.pk]];

    if(sqlite3_step(statement) == SQLITE_ROW) {
        [self loadObject:o fromRow:statement storedInTable:tableName];
    } else {
        LOG2(@"Reload of %@ failed: no record with such id", o);
    }
    
    sqlite3_finalize(statement);
}

@end
