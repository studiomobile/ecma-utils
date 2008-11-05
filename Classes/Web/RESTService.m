#import "RESTService.h"
#import "POXMapping.h"
#import "NSObject+Utils.h"
#import "NSString+Utils.h"

const NSString *WebServiceErrorKey = @"__WebServiceError__";
const NSString *RequestStatusCode = @"__RequestStatusCode__";

@implementation RESTService

- (id)initWithBaseUrl:(NSString*)url locale:(NSString*)localeCode {
	checkNotNil(url, @"nil url");
	checkNotNil(localeCode, @"nil locale");
	if (self = [super init]) {
		baseUrl = [url retain];
		locale = [localeCode retain];
	}
	return self;
}

- (void)dealloc {
	[baseUrl release];
	[locale release];
	[super dealloc];
}

- (NSMutableURLRequest*)queryString:(NSString*)localPath :(NSDictionary*)params {
	NSMutableString *queryString = [NSMutableString stringWithCapacity:100];
	[queryString appendString:baseUrl];
	[queryString appendString:localPath];
	BOOL first = YES;
	for(NSString *key in params) {
		if(first) {
			[queryString appendString:@"?"];
		} else {
			[queryString appendString:@"&"];
		}
		[queryString appendString:[key urlEncode]];
		[queryString appendString:@"="];
		[queryString appendString:[[params objectForKey:key] urlEncode]];
		first = NO;
	}
	return [NSMutableURLRequest requestWithURL:[NSURL URLWithString:queryString]];
}

- (id)mapData:(NSData*)data error:(NSError**)error{
	NSXMLParser *parser = [[NSXMLParser alloc] initWithData:data];
	POXMapping *mapper = [[POXMapping alloc] init];
	[parser setDelegate:mapper];
	if(![parser parse]) {
		NSLog(@"Parse error");
		*error = [[[parser parserError] retain] autorelease];
	}
	id result = [[[mapper result] retain] autorelease];
	[parser release];
	[mapper release];
	return result;
}

- (id)request:(NSURLRequest*)request error:(NSError**)error {
	NSHTTPURLResponse *response = nil;
	NSLog(@"Requesting %@", [request URL]);
	NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:error];
	if(data) {
		NSUInteger statusCode = [response statusCode];
		NSLog(@"Status code: %d", statusCode);
		id result = [data length] > 0 ? [self mapData:data error:error] : nil;
		if(statusCode == 200) {
			return result;
		} else {
			if(result) {
				NSDictionary *errorInfo = [NSDictionary dictionaryWithObjectsAndKeys:
										   result, WebServiceErrorKey, 
										   [NSNumber numberWithInt:statusCode], RequestStatusCode, 
										   nil];
				*error = [NSError errorWithDomain:@"WebServerError" code:1 userInfo:errorInfo];
			} else {
				NSLog(@"Failed to map server error to provided erro class");
				NSDictionary *errorInfo = [NSDictionary dictionaryWithObjectsAndKeys:
										   NSLocalizedDescriptionKey, @"Unexpected server error", 
										   [NSNumber numberWithInt:statusCode], RequestStatusCode,
										   nil];
				*error = [NSError errorWithDomain:@"WebServerError" code:1 userInfo:errorInfo];
			}
		}
	} else {
		NSLog(@"Request failed with error:%@", [*error localizedDescription]);
	}
	return nil;
}

- (id)get:(NSString*)localPath withParams:(NSDictionary*)params error:(NSError**)error{
	checkNotNil(localPath, @"localPath cannot be nil");
	
	NSMutableURLRequest *request = [self queryString:localPath :params];
	[request setHTTPMethod:@"GET"];
	return [self request:request error:error];
}

- (id)post:(NSData*)data to:(NSString*)localPath error:(NSError**)error {
	checkNotNil(localPath, @"localPath cannot be nil");
	checkNotNil(data, @"data cannot be nil");
	NSMutableURLRequest *request = [self queryString:localPath :nil];
	[request addValue:@"text/xml" forHTTPHeaderField:@"Content-Type"];

	[request setHTTPMethod:@"POST"];
	[request setHTTPBody:data];
	return [self request:request error:error];
}

@end
