#import "NSString+Utils.h"
#import "NSObject+Utils.h"

//convert base64 alphabet charcter into corresponding number
static unsigned char decode(char c) {	
	if(c >= 'A' && c <= 'Z') return(c - 'A');
	if(c >= 'a' && c <= 'z') return(c - 'a' + 26);
	if(c >= '0' && c <= '9') return(c - '0' + 52);
	if(c == '+')             return 62;
	return 63;
}

int from_base64(const char *data, size_t dataLen, void **result, size_t *resultLen) {
	checkNotNull((void*)data, @"Data can not be null");
	checkArgument(dataLen >= 0, @"dataLen cannot be less than 0");
	checkNotNull(result, @"result cannot be null");
	checkNotNull(resultLen, @"resultLen cannot be null");
	checkArgument(dataLen%4 == 0, @"Invalid base64 string");
	if(data[dataLen - 1] == '=' && data[dataLen - 2] == '=') {
		*resultLen = (dataLen/4)*3 - 2;
	} else if(data[dataLen - 1] == '=') {
		*resultLen = (dataLen/4)*3 - 1;
	} else {
		*resultLen = (dataLen/4)*3;
	}
	char *buf = (char*)malloc(sizeof(char)*(*resultLen));
	for(int i = 0, j = 0; i < dataLen; i += 4, j += 3) {
		buf[j] = (decode(data[i]) << 2) | (decode(data[i + 1]) >> 4);
		buf[j + 1] = data[i + 2] != '=' ? ((decode(data[i + 1]) & 0xF) << 4) | (decode(data[i + 2]) >> 2) : '\0';
		buf[j + 2] = data[i + 3] != '=' ? (decode(data[i + 2]) << 6) | decode(data[i + 3]) : '\0';
	}
	*result = buf;
	return 0;
}


@implementation NSString(Utils)

- (NSData*)fromBase64 {
	const char *cStr = [self cStringUsingEncoding:NSASCIIStringEncoding];
	size_t cStrLen = strlen(cStr);
	void *data = NULL;
	size_t size;
	int result = from_base64(cStr, cStrLen, &data, &size);
	if(result == 0) {
		return [NSData dataWithBytesNoCopy:data length:size];
	} else {
		return nil;
	}
}

- (BOOL)isEmpty {
	return [[self stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"\n\r\t "]] isEqualToString:@""];
}

- (BOOL)isNotEmpty {
	return ![self isEmpty];
}

- (NSString *)trimSpaces {
	return [self stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"\n\r\t "]];
}

- (NSString *)trim:(NSString*)chars {
	return [self stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:chars]];
}

- (NSURL*)toUrl {
    return [NSURL URLWithString:self];
}

- (NSURL*)toFileUrl {
    return [NSURL fileURLWithPath:self];
}


- (NSString*)urlEncode {
	return [self urlEncode:nil];
}

- (NSString*)urlEncode:(NSString*)additionalCharacters {
	NSString* str = (NSString*)CFURLCreateStringByAddingPercentEscapes(NULL, (CFStringRef)self, NULL, (CFStringRef)additionalCharacters, kCFStringEncodingUTF8);
	return [str autorelease];
}

- (NSString*)urlDecode {
    return [self urlDecode:@""];
}

- (NSString*)urlDecode:(NSString*)additionalCharacters {
    NSString *str = (NSString*)CFURLCreateStringByReplacingPercentEscapes(NULL, (CFStringRef)self, (CFStringRef)additionalCharacters);
    return [str autorelease];
}

@end
