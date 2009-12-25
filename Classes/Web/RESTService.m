#import "RESTService.h"
#import "NSObject+Utils.h"
#import "NSString+Web.h"
#import "NSData+Base64.h"

#import "UIAlertView+Utils.h"

NSString* const WebServiceErrorDomain = @"WebServerError";
NSString *const WebServiceErrorKey = @"__WebServiceError__";
NSString *const RequestStatusCode = @"__RequestStatusCode__";

@implementation RESTService

@synthesize baseUrl;
@synthesize login;
@synthesize password;
@synthesize timeoutInterval;
@synthesize enableCookies;

- (id)initWithBaseUrl:(NSString*)url mapper:(NSObject<RESTServiceDataMapper>*)m {
	checkNotNil(url, @"nil url");
    if (![super init]) return nil;
    baseUrl = [url retain];
    mapper = [m retain];
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


- (NSMutableURLRequest*)requestForPath:(NSString*)localPath withParams:(WebParams*)params {
    NSString *queryString = params.queryString;
	NSMutableString *url = [NSMutableString stringWithCapacity:baseUrl.length + localPath.length + queryString.length];
	[url appendString:baseUrl];
	[url appendString:localPath];
    if (queryString) {
        [url appendString:queryString];
    }
	NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]];
    [request setHTTPShouldHandleCookies:enableCookies];
	
	if (timeoutInterval > 0) {
        [request setTimeoutInterval:timeoutInterval];
    }
	if (login.length > 0 && password.length > 0) {
		NSString *authString = [[[NSString stringWithFormat:@"%@:%@", login, password] dataUsingEncoding:NSUTF8StringEncoding] base64EncodedString];
		authString = [NSString stringWithFormat: @"Basic %@", authString];
		[request setValue:authString forHTTPHeaderField:@"Authorization"];
	}
	return request;
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
		if(statusCode < 400) {
			return result;
		} else {
			if(result) {
				NSDictionary *errorInfo = [NSDictionary dictionaryWithObjectsAndKeys:
										   result, WebServiceErrorKey, 
										   [NSNumber numberWithInt:statusCode], RequestStatusCode, 
										   nil];
				*error = [NSError errorWithDomain:WebServiceErrorDomain code:1 userInfo:errorInfo];
                NSLog(@"Result: %@", [[NSString alloc] initWithData:result encoding:NSUTF8StringEncoding]);
			} else {
				NSLog(@"Failed to map server error to provided erro class");
				NSDictionary *errorInfo = [NSDictionary dictionaryWithObjectsAndKeys:
										   NSLocalizedDescriptionKey, @"Unexpected server error", 
										   [NSNumber numberWithInt:statusCode], RequestStatusCode,
										   nil];
				*error = [NSError errorWithDomain:WebServiceErrorDomain code:1 userInfo:errorInfo];
			}
		}
	} else {
		NSLog(@"Request failed with error:%@", [*error localizedDescription]);
	}
	return nil;
}


- (id)get:(NSString*)localPath withParams:(WebParams*)params error:(NSError**)error{
	checkNotNil(localPath, @"localPath cannot be nil");
	
	NSMutableURLRequest *request = [self requestForPath:localPath withParams:params];
	[request setHTTPMethod:@"GET"];
	return [self request:request error:error];
}


- (id)get:(NSString*)localPath withParams:(WebParams*)params headers:(NSDictionary*)headers error:(NSError**)error{
	checkNotNil(localPath, @"localPath cannot be nil");
	
	NSMutableURLRequest *request = [self requestForPath:localPath withParams:params];
    for (NSString *header in headers) {
        NSString *val = [headers objectForKey:header];
        [request addValue:val forHTTPHeaderField:header];
    }
	[request setHTTPMethod:@"GET"];
	return [self request:request error:error];
}

- (id)del:(NSString*)localPath withParams:(WebParams*)params error:(NSError**)error{
	checkNotNil(localPath, @"localPath cannot be nil");
	
	NSMutableURLRequest *request = [self requestForPath:localPath withParams:params];
	[request setHTTPMethod:@"DELETE"];
	return [self request:request error:error];
}


- (id)send:(NSData*)data to:(NSString*)localPath method:(NSString*)method contentType:(NSString*)contentType headers:(NSDictionary*)headers error:(NSError**)error {
    checkNotNil(localPath, @"localPath cannot be nil");
    checkNotNil(data, @"data cannot be nil");
    NSMutableURLRequest *request = [self requestForPath:localPath withParams:nil];
    for (NSString *header in headers) {
        NSString *val = [headers objectForKey:header];
        [request addValue:val forHTTPHeaderField:header];
    }
	if (contentType) {
		[request addValue:contentType forHTTPHeaderField:@"Content-Type"];
	}
    [request addValue:[NSString stringWithFormat:@"%d", [data length]] forHTTPHeaderField:@"Content-Length"];
    [request setHTTPMethod:method];
    [request setHTTPBody:data];
	
    return [self request:request error:error];    
}

- (id)post:(NSData*)data contentType:(NSString*)contentType to:(NSString*)localPath headers:(NSDictionary*)headers error:(NSError**)error {
	return [self send:data to:localPath method:@"POST" contentType:contentType headers:headers error:error];
}

- (id)post:(NSData*)data contentType:(NSString*)contentType to:(NSString*)localPath error:(NSError**)error {
    NSDictionary *headers = [NSDictionary dictionaryWithObjectsAndKeys:@"text/xml", @"Accept", nil];
	return [self post:data contentType:contentType to:localPath headers:headers error:error];
}

- (id)put:(NSData*)data contentType:(NSString*)contentType to:(NSString*)localPath headers:(NSDictionary*)headers error:(NSError**)error {
	return [self send:data to:localPath method:@"PUT" contentType:contentType headers:headers error:error];
}

- (id)put:(NSData*)data contentType:(NSString*)contentType to:(NSString*)localPath error:(NSError**)error {
    NSDictionary *headers = [NSDictionary dictionaryWithObjectsAndKeys:@"text/xml", @"Accept", nil];
	return [self put:data contentType:contentType to:localPath headers:headers error:error];
}



@end