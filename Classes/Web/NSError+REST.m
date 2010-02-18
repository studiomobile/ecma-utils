#import "NSError+REST.h"
#import "RESTService.h"

@implementation NSError(REST)

- (NSString*)detailedRESTDescription {    
	NSString* restErrorMessage = nil;
	if([self.domain isEqual: WebServiceErrorDomain]){		
		id restErrorData = [self.userInfo objectForKey: WebServiceErrorKey];
		if(restErrorData && [restErrorData isKindOfClass: [NSData class]]){
			restErrorMessage = [[[NSString alloc] initWithData: restErrorData 
													  encoding: NSUTF8StringEncoding] autorelease];
			return restErrorMessage;
		}
	}
	
	return nil;
}

@end
