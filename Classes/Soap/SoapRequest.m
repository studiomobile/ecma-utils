#import "Soap.h"
#import "SoapRequest.h"
#import "RESTService.h"

#import "Reachability+Utils.h"

#import "SoapDebugLogEnveloper.h"
#import "ESLogger.h"


NSString * const kSoapLogTag = @"SOAP";

@interface SoapRequest ()
@property (retain, readwrite) id result; 
@property (retain, readwrite) NSError* error; 
@end


@implementation SoapRequest

@synthesize header;
@synthesize url;
@synthesize action;
@synthesize body;
@synthesize responseType;
@synthesize responseIsMany;
@synthesize pathToResult;
@synthesize	result; 
@synthesize	error; 
@synthesize enableCookies;

- (void)dealloc {
	[url release];
	[action release];
	[header release];
	[body release];
	[responseType release];
	[pathToResult release];
	[result release]; 
	[error release]; 
	[super dealloc];
}

- (id)getResultFrom:(NSData*)data {
	NSString* responseString = [[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] autorelease];
	ESLog(kSoapLogTag, @"SOAP RESPONSE:\n%@", responseString);	
	SoapDeenveloper* deenveloper = [SoapDeenveloper soapDeenveloperWithXmlString:responseString];			
	
	if (responseIsMany) {
		return [deenveloper decodeBodyObjectsOfType: responseType];
	}

    id res = [deenveloper decodeBodyObjectOfType: responseType];
    if (pathToResult) {
        res = [res objectForPath: pathToResult];
    }
    return res;
}


- (BOOL)execute {	
	self.error = nil;
	self.result = nil;
	
	NSURL* _url = [[[NSURL alloc] initWithString: url] autorelease];	
	if(self.error = [Reachability hostReachabilityError: _url.host]){
		return NO;
	}
	
	RESTService *service = [[[RESTService alloc] initWithBaseUrl:url] autorelease];
	service.enableCookies = enableCookies;
	
	SoapEnveloper *enveloper = [SoapEnveloper soapEnveloper];
	
	if (header) {
		[enveloper encodeHeaderObject:header];
	}
	[enveloper encodeBodyObject:body];
	
	NSString *xmlString = enveloper.message;
	
	NSString *logMessage = nil;
	if([ESLogger isVerboseLogging:kSoapLogTag]) {
		logMessage = xmlString;
	} else {
		SoapEnveloper* debugEnveloper = [SoapDebugLogEnveloper soapEnveloper];
		if (header) {
			[debugEnveloper encodeHeaderObject:header];
		}
		[debugEnveloper encodeBodyObject:body];
		logMessage = debugEnveloper.message;
	}
	ESLog(kSoapLogTag, @"SOAP REQUEST at %@:\n%@", url, logMessage);	
	
	NSData *requestData = [xmlString dataUsingEncoding: NSUTF8StringEncoding];
	
	NSError* err = nil;
	NSString* actionString = action ? [NSString stringWithFormat: @"; action=\"%@\"", action] : @"";
	NSString* contentTypeString = [NSString stringWithFormat:@"application/soap+xml; charset=utf-8%@", actionString];
	NSData* responseData = [service post:requestData contentType:contentTypeString to:@"" error: &err];
	if(err){
		self.error = err;
		return NO;
	}
	
	self.result = [self getResultFrom: responseData];
	return YES;
}


@end

@implementation SoapRequest (Async)

- (id)executeAndReturnResultOrError {
	if ([self execute]) {
		return self.result;
	} else {
		return self.error;
	}	
}

@end
