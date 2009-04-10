#import "WebParams.h"

@implementation WebParams

+ (WebParams*)params {
	return [[WebParams new] autorelease];
}


- (id)init {
	if (self = [super init]) {
		params = [NSMutableDictionary new];
	}
	return self;
}


- (id)initWithDictionary:(NSDictionary*)dictionary {
	if (self = [super init]) {
		params = [[NSMutableDictionary alloc] initWithDictionary:dictionary];
	}
	return self;
}


- (void)addParam:(id)param forKey:(id)key {
	if (param) {
		multipart |= [param isKindOfClass:[NSData class]];
		[params setObject:param forKey:key];
	}
}


- (NSString*)queryString {
	NSMutableString *queryString = [NSMutableString string];
	for(NSString *key in params) {
		NSObject *value = [params objectForKey:key];
		if ([value isKindOfClass:[NSData class]]) continue;
		[queryString appendString:@"&"];
		[queryString appendString:[[key description] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
		[queryString appendString:@"="];
		[queryString appendString:[[value description] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
	}
	[queryString replaceCharactersInRange:NSMakeRange(0, 1) withString:@"?"];
	return [queryString description];
}


- (NSString*)boundary {
	return [[UIDevice currentDevice] uniqueIdentifier];
}


- (NSString*)contentType {
	return multipart ? [NSString stringWithFormat:@"multipart/form-data; boundary=%@", self.boundary] : @"application/x-www-form-urlencoded";
}


- (NSData*)multipartPostData {
	NSMutableData *postData = [NSMutableData data];
	
    [postData appendData:[[NSString stringWithFormat:@"--%@\r\n", self.boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    
	for(NSString *key in params) {
		NSObject *value = [params objectForKey:key];
		if ([value isKindOfClass:[NSData class]]) {
			[postData appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"; filename=\"%@\"\r\n\r\n", key, key] dataUsingEncoding:NSUTF8StringEncoding]];
			[postData appendData:(NSData*)value];
		} else {
			[postData appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n", key] dataUsingEncoding:NSUTF8StringEncoding]];
			[postData appendData:[[(NSString*)value description] dataUsingEncoding:NSUTF8StringEncoding]];
		}
	}

    [postData appendData:[[NSString stringWithFormat:@"\r\n--%@--\r\n", self.boundary] dataUsingEncoding:NSUTF8StringEncoding]];
	
	return postData;
}


- (NSData*)postData {
	if (multipart) {
		return self.multipartPostData;
	}

	NSMutableString *queryString = [NSMutableString stringWithString:self.queryString];
	[queryString replaceCharactersInRange:NSMakeRange(0, 1) withString:@""];
	return [queryString dataUsingEncoding:NSUTF8StringEncoding];
}


- (void)dealloc {
	[params release];
	[super dealloc];
}

@end
