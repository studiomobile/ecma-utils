#import "Reachability.h"
#import "Reachability+Utils.h"
#import "NSError+Utils.h"

@implementation Reachability (Utils)

+(void)	setHostName: (NSString*)hostName{
	[Reachability sharedReachability].hostName = hostName;
}

+(void)	setAddress: (NSString*)address{
	[Reachability sharedReachability].address = address;
}

+(BOOL)	isNetworkReachable{
	return [[Reachability sharedReachability] remoteHostStatus] != NotReachable;
}

+(NSError*)defaultReachabilityError{
	return [NSError errorWithDomain:@"defaultDomain"
							   code:0
						description:@"Network is not reachable."];	
}

+(id)	reachabilityError{
	return [self isNetworkReachable] ? nil : [self defaultReachabilityError];	
}

+(id)	hostReachabilityError: (NSString*)hostName{
	return [[Reachability sharedReachability] isHostReachable: hostName] ? nil : [self defaultReachabilityError];
}


@end
