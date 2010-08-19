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


- (void)setParam:(id)_param forKey:(id)key {
	if (!_param) return;
	multipart |= [self isFileUpload:_param];
	[params setObject:_param forKey:key];
}


- (void)addParam:(id)_param forKey:(id)key {
	if (!_param) return;
	multipart |= [self isFileUpload:_param];
	id value = [params objectForKey:key];
	if (value) {
		if (![value isKindOfClass:[NSMutableArray class]]) {
			if ([value isKindOfClass:[NSArray class]]) {
				value = [NSMutableArray arrayWithArray:value];
			} else {
				value = [NSMutableArray arrayWithObject:value];
			}
			[params setObject:value forKey:key];
		}
		if ([_param isKindOfClass:[NSArray class]]) {
			[(NSMutableArray*)value addObjectsFromArray:_param];
		} else {
			[(NSMutableArray*)value addObject:_param];
		}
	} else {
		[params setObject:_param forKey:key];
	}
}


- (NSString*)encodeQueryValue:(id)value {
	return [[value description] urlEncode:@"\"%;/?:@&=+$,[]#!'()*"];
}


- (void)appendToQueryString:(NSMutableString*)queryString key:(NSString*)key value:(id)value {
	[queryString appendString:@"&"];
	[queryString appendString:[self encodeQueryValue:key]];
	[queryString appendString:@"="];
	[queryString appendString:[self encodeQueryValue:value]];
}


- (NSString*)queryString {
	NSMutableString *queryString = [NSMutableString string];
	for (NSString *key in params) {
		NSObject *value = [params objectForKey:key];
		if ([self isFileUpload:value]) continue;
		if ([value conformsToProtocol:@protocol(NSFastEnumeration)]) {
			for (id v in value) {
				[self appendToQueryString:queryString key:key value:v];
			}
		} else {
			[self appendToQueryString:queryString key:key value:value];
		}
	}
	if (queryString.length) {
		[queryString replaceCharactersInRange:NSMakeRange(0, 1) withString:@"?"];
	}
	return queryString;
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
			NSString *contentType = [value respondsToSelector:@selector(contentType)] ? [(id)value contentType] : @"application/octet-stream";
            NSData *data = [value respondsToSelector:@selector(data)] ? [(id)value data] : (NSData*)value;
			[postData appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"; filename=\"%@\"\r\nContent-Type: %@\r\nContent-Transfer-Encoding: binary\r\n\r\n", key, contentType, filename] dataUsingEncoding:NSUTF8StringEncoding]];
			[postData appendData:data];
		} else {
			if ([value conformsToProtocol:@protocol(NSFastEnumeration)]) {
				for (id v in value) {
					[postData appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n", key] dataUsingEncoding:NSUTF8StringEncoding]];
					[postData appendData:[[v description] dataUsingEncoding:NSUTF8StringEncoding]];
				}
			} else {
				[postData appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n", key] dataUsingEncoding:NSUTF8StringEncoding]];
				[postData appendData:[[value description] dataUsingEncoding:NSUTF8StringEncoding]];
			}
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
	if (multipart) return [self multipartPostData];
	NSMutableString *queryString = (NSMutableString*)self.queryString;
	[queryString deleteCharactersInRange:NSMakeRange(0, 1)];
	return [queryString dataUsingEncoding:NSUTF8StringEncoding];
}


- (NSURL*)appendToURL:(NSURL*)url {
	if (params.count == 0) return url;
	BOOL haveParams = [[url absoluteString] rangeOfString:@"?"].length > 0;
	NSMutableString *queryString = (NSMutableString*)self.queryString;
	[queryString replaceCharactersInRange:NSMakeRange(0, 1) withString:haveParams ? @"&" : @"?"];
	return [NSURL URLWithString:queryString relativeToURL:url];
}


- (void)dealloc {
	[params release];
	[super dealloc];
}

@end
