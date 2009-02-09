#import "NSData+Utils.h"
#import "NSObject+Utils.h"

static const char *base64alphabet = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";

int to_base64(const char *data, size_t dataLen, char **base64Result, size_t *base64ResultSize) {
	checkNotNull((void*)data, @"Data can not be null");
	checkArgument(dataLen >= 0, @"dataLen cannot be less than 0");
	checkNotNull(base64Result, @"base64Result cannot be null");
	checkNotNull(base64ResultSize, @"base64DataSize cannot be null");
	
	NSUInteger safeBytes = (dataLen/3)*3; //we can safely encode this amount of bytes without thinking about padding
	NSUInteger unsafeBytes = dataLen - safeBytes;
	NSUInteger base64DataLen = (safeBytes/3)*4 + (unsafeBytes == 0 ? 0 : 4) ;
	char *base64Data = (char*)malloc(sizeof(char)*base64DataLen);
	for(int i = 0, j = 0; i < safeBytes; i += 3, j += 4) {
		base64Data[j] = base64alphabet[data[i] >> 2]; //first 6 bits
		base64Data[j + 1] = base64alphabet[((data[i] & 0x03) << 4) | (data[i + 1] >> 4)]; //last 2 bits and first 4 bits
		base64Data[j + 2] = base64alphabet[((data[i + 1] & 0x0F) << 2) | (data[i + 2] >> 6)]; //last 4 bits and first 2 bits
		base64Data[j + 3] = base64alphabet[data[i + 2] & 0x3F]; //last 6 bits
	}
	//add padding characters
	if(unsafeBytes != 0) {
		char dataAndPadding[3] = {'\0','\0','\0'};
		memcpy(dataAndPadding, data + safeBytes, unsafeBytes);
		NSUInteger bytesWrittenSoFar = 4*safeBytes/3;
		base64Data[bytesWrittenSoFar] = base64alphabet[dataAndPadding[0] >> 2];
		base64Data[bytesWrittenSoFar + 1] = base64alphabet[((dataAndPadding[0] & 0x03) << 4) | (dataAndPadding[1] >> 4)];
		if(unsafeBytes == 2) {
			base64Data[bytesWrittenSoFar + 2] = base64alphabet[((dataAndPadding[1] & 0x0F) << 2) | (dataAndPadding[2] >> 6)];	
		} else {
			base64Data[bytesWrittenSoFar + 2] = '=';
		}
		base64Data[bytesWrittenSoFar + 3] = '=';
	}
	*base64ResultSize = base64DataLen;
	*base64Result = base64Data;
	return 0;
}

@implementation NSData(Utils)

- (NSString*)toBase64 {
	//see base64 RFC for details
	const char *data = [self bytes];
	size_t dataLen = [self length];
	size_t base64DataSize = 0;
	char *base64 = NULL;
	NSUInteger result = to_base64(data, dataLen, &base64, &base64DataSize);
	if(result == 0) {
		return [[[NSString alloc] 
				 initWithBytesNoCopy:base64
				 length:base64DataSize 
				 encoding:NSASCIIStringEncoding 
				 freeWhenDone:YES] autorelease];
	} else {
		return nil;
	}
}

@end
