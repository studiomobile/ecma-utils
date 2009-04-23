#import <UIKit/UIKit.h>

int from_base64(const char *data, size_t dataLen, void **result, size_t *resultLen);

@interface NSString(Utils)

- (NSData*)fromBase64;

- (BOOL)isEmpty;
- (BOOL)isNotEmpty;
- (NSString *)trimSpaces;
- (NSString *)trim:(NSString*)chars;

- (BOOL)caseInsensitiveStartsWith:(NSString*)prefix;
- (BOOL)startsWith:(NSString*)prefix;
- (BOOL)caseInsensitiveEndsWith:(NSString*)suffix;
- (BOOL)endsWith:(NSString*)suffix;

- (NSURL*)toUrl;
- (NSURL*)toFileUrl;
- (NSString*)urlEncode:(NSString*)additionalCharacters;
- (NSString*)urlEncode;
- (NSString*)urlDecode;
- (NSString*)urlDecode:(NSString*)additionalCharacters;

+ (NSString *)formattedInt:(int)value;

@end
