#import <UIKit/UIKit.h>
#import <sqlite3.h>
#import "DBSession.h"

#define kDBErrorDomain @"DBErrorDomain"
extern const NSUInteger kFailedToOpenDB;

@interface DB : NSObject {
	NSString *dbName;
	sqlite3 *impl;
}

+ (DB*)dbWithName:(NSString*)db error:(NSError**)error;
- (id)initWithDBName:(NSString*)db error:(NSError**)error;
- (sqlite3*)impl;
- (DBSession*)createSession;

@end
