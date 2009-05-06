#import "RESTService.h"
#import "POXMapping.h"
#import "NSObject+Utils.h"
#import "NSString+Utils.h"

const NSString *WebServiceErrorKey = @"__WebServiceError__";
const NSString *RequestStatusCode = @"__RequestStatusCode__";

@implementation RESTService

@synthesize baseUrl;
@synthesize additionalUrlEncodechars;

- (id)initWithBaseUrl:(NSString*)url mapper:(id<RESTServiceDataMapper>)m {
	checkNotNil(url, @"nil url");

	if (self = [super init]) {
		baseUrl = [url retain];
        mapper = [m retain];
	}
	return self;
}

- (id)initWithBaseUrl:(NSString*)url {
    return [self initWithBaseUrl:url mapper:nil];
}

- (void)dealloc {
    [mapper release];
	[baseUrl release];
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
        if(self.additionalUrlEncodechars) {
            [queryString appendString:[key urlEncode:self.additionalUrlEncodechars]];
            [queryString appendString:@"="];
            [queryString appendString:[[params objectForKey:key] urlEncode:self.additionalUrlEncodechars]];
        } else {
            [queryString appendString:[key urlEncode]];
            [queryString appendString:@"="];
            [queryString appendString:[[params objectForKey:key] urlEncode]];
        }
		first = NO;
	}
	return [NSMutableURLRequest requestWithURL:[NSURL URLWithString:queryString]];
}

- (id)mapData:(NSData*)data error:(NSError**)error{
    if(!mapper) return data;
    return [mapper map:data];
}

- (id)request:(NSURLRequest*)request error:(NSError**)error {
	NSHTTPURLResponse *response = nil;
#ifdef DEBUG_LOG
	NSLog(@"Requesting %@", [request URL]);
#endif
	NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:error];
	if(data) {
		NSUInteger statusCode = [response statusCode];
#ifdef DEBUG_LOG
		NSLog(@"Status code: %d", statusCode);
#endif
		id result = data ? [self mapData:data error:error] : nil;
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

- (id)post:(NSData*)data to:(NSString*)localPath headers:(NSDictionary*)headers error:(NSError**)error {
    checkNotNil(localPath, @"localPath cannot be nil");
    checkNotNil(data, @"data cannot be nil");
    NSMutableURLRequest *request = [self queryString:localPath :nil];
    for (NSString *header in headers) {
        NSString *val = [headers objectForKey:header];
        [request addValue:val forHTTPHeaderField:header];
    }
    [request addValue:[NSString stringWithFormat:@"%d", [data length]] forHTTPHeaderField:@"Content-Length"];
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:data];

    return [self request:request error:error];    
}

- (id)post:(NSData*)data to:(NSString*)localPath error:(NSError**)error {
    NSDictionary *headers = [NSDictionary dictionaryWithObjectsAndKeys:@"text/xml", @"Content-Type", nil];
    return [self post:data to:localPath headers:headers error:error];
}

@end
