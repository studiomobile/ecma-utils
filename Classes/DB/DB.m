#import "DB.h"

const NSUInteger kFailedToOpenDB = 1;
@implementation DB

- (DBSession*)createSession {
	return [[DBSession alloc] initWithDB:self];
}

-(NSString*) checkAndCreateDatabase:(NSError**)error{
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

+ (DB*)dbWithName:(NSString*)db error:(NSError**)error {
	return [[[DB alloc] initWithDBName:db error:error] autorelease];
}

- (void) dealloc {
	if(impl != NULL) {
		sqlite3_close(impl);		
	}
	[dbName release];
	[super dealloc];
}


- (sqlite3*)impl {
	return impl;
}

@end
