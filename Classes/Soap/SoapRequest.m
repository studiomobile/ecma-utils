#import "Soap.h"
#import "SoapRequest.h"
#import "RESTService.h"

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

- (void)dealloc {
	[url release];
	[action release];
	[header release];
	[(NSObject*)body release];
	[responseType release];
	[pathToResult release];
	[result release]; 
	[error release]; 
	[super dealloc];
}

- (id)getResultFrom:(NSData*)data {
	NSString* responseString = [[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] autorelease];
	NSLog(@"SOAP RESPONSE:\n%@", responseString);	
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
	
	RESTService *service = [[[RESTService alloc] initWithBaseUrl:url] autorelease];

	SoapEnveloper *enveloper = [SoapEnveloper soapEnveloper];
	if (header) {
		[enveloper encodeHeaderObject:header];
	}
	[enveloper encodeBodyObject:body];
	
	NSString *xmlString = enveloper.message;
	NSLog(@"SOAP REQUEST:\n%@", xmlString);
	NSData *requestData = [xmlString dataUsingEncoding: NSUTF8StringEncoding];
	
	NSError* err = nil;
	NSString* actionString = action ? [NSString stringWithFormat: @"; action=\"%@\"", action] : @"";
	NSString* contentTypeString = [NSString stringWithFormat:@"application/soap+xml; charset=utf-8%@", actionString];
	NSData* responseData = [service post:requestData contentType: contentTypeString to:@"" error: &err];
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
