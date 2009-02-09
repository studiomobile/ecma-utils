#import <UIKit/UIKit.h>

int from_base64(const char *data, size_t dataLen, void **result, size_t *resultLen);

@interface NSString(Utils)

+ (NSString*)join:(NSArray*)items delimiter:(NSString*)d selector:(SEL)s;
+ (NSString*)join:(NSArray*)items delimiter:(NSString*)d;

- (NSData*)fromBase64;

- (BOOL)isEmpty;
- (BOOL)isNotEmpty;
- (NSString *)trimSpaces;
- (NSString *)trim:(NSString*)chars;

- (NSURL*)toUrl;
- (NSURL*)toFileUrl;
- (NSString*)urlEncode:(NSString*)additionalCharacters;
- (NSString*)urlEncode;
- (NSString*)urlDecode;
- (NSString*)urlDecode:(NSString*)additionalCharacters;

@end
