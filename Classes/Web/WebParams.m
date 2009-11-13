#import <UIKit/UIKit.h>
#import "WebParams.h"
#import "NSString+Web.h"

@implementation WebParams

+ (WebParams*)params {
	return [[WebParams new] autorelease];
}


- (id)initWithDictionary:(NSDictionary*)dictionary {
	if (![super init]) return nil;
    params = [[NSMutableDictionary alloc] initWithDictionary:dictionary];
	return self;
}


- (id)init {
    return [self initWithDictionary:[NSDictionary dictionary]];
}


- (BOOL)isFileUpload:(id)param {
    return [param isKindOfClass:[NSData class]] || [param isKindOfClass:[FileUpload class]];
}


- (void)addParam:(id)param forKey:(id)key {
	if (param) {
		multipart |= [self isFileUpload:param];
		[params setObject:param forKey:key];
	}
}


- (NSString*)queryString {
	NSMutableString *queryString = [NSMutableString string];
	for (NSString *key in params) {
		NSObject *value = [params objectForKey:key];
		if ([self isFileUpload:value]) continue;
		[queryString appendString:@"&"];
		[queryString appendString:[[key description] urlEncode:@"&="]];
		[queryString appendString:@"="];
		[queryString appendString:[[value description] urlEncode:@"&="]];
	}
	if (queryString.length) {
		[queryString replaceCharactersInRange:NSMakeRange(0, 1) withString:@"?"];
	}
	return [[queryString copy] autorelease];
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
    NSArray *keys = [params allKeys];
	for (int i = 0; i < keys.count; ++i) {
		NSString *key = [keys objectAtIndex:i];
		NSObject *value = [params objectForKey:key];
		if ([self isFileUpload:value]) {
            NSString *filename = [value respondsToSelector:@selector(filename)] ? [(id)value fileName] : key;
            NSData *data = [value respondsToSelector:@selector(data)] ? [(id)value data] : (NSData*)value;
			[postData appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"; filename=\"%@\"\r\nContent-Type: image/jpeg\r\nContent-Transfer-Encoding: binary\r\n\r\n", key, filename] dataUsingEncoding:NSUTF8StringEncoding]];
			[postData appendData:data];
		} else {
			[postData appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n", key] dataUsingEncoding:NSUTF8StringEncoding]];
			[postData appendData:[[value description] dataUsingEncoding:NSUTF8StringEncoding]];
		}
		if (i == keys.count - 1) {
			[postData appendData:[[NSString stringWithFormat:@"\r\n--%@--", self.boundary] dataUsingEncoding:NSUTF8StringEncoding]];
		} else {
			[postData appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n", self.boundary] dataUsingEncoding:NSUTF8StringEncoding]];
		}
	}
	
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
