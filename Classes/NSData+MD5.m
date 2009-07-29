#import "NSData+MD5.h"
#import <CommonCrypto/CommonDigest.h>


@implementation NSData (MD5)

- (NSString*)md5 {
    unsigned char md5[16];
    CC_MD5([self bytes], [self length], md5);
    return [NSString stringWithCString:(char*)md5 length:16];
}

@end
