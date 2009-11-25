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

+(id)	reachabilityError{
	if([self isNetworkReachable]) {
		return nil;
	} else {
		return [NSError errorWithDomain:@"defaultDomain"
								   code:0
							description:@"Network is not reachable."];
	}
	
}


@end
