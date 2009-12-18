#import "Reachability.h"

@interface Reachability (Utils)

+(void)	setHostName: (NSString*)hostName;
+(void)	setAddress: (NSString*)address;
+(BOOL)	isNetworkReachable;
+(id)	reachabilityError;
+(id)	hostReachabilityError: (NSString*)hostName;


@end