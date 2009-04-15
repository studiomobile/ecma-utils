#import <UIKit/UIKit.h>

int to_base64(const unsigned char *data, size_t dataLen, unsigned char **base64Data, size_t *base64DataSize);

@interface NSData(Utils)

- (NSString*)toBase64;

@end
