#import <UIKit/UIKit.h>

int from_base64(const char *data, size_t dataLen, void **result, size_t *resultLen);

@interface NSString(Utils)

- (NSData*)fromBase64;

- (BOOL)isEmpty;
- (BOOL)isNotEmpty;
- (NSString *)trimSpaces;
- (NSString *)trim:(NSString*)chars;

- (NSURL*)toUrl;
- (NSString*)urlEncode:(NSString*)additionalCharacters;
- (NSString*)urlEncode;

@end