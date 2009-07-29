#import "NSData+MD5.h"
#import <CommonCrypto/CommonDigest.h>


@implementation NSData (MD5)

- (NSString*)md5 {
    unsigned char md5[16];
    CC_MD5([self bytes], [self length], md5);
	return [NSString stringWithFormat:@"%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X",
            md5[0], md5[1], md5[2],  md5[3],  md5[4],  md5[5],  md5[6],  md5[7],
            md5[8], md5[9], md5[10], md5[11], md5[12], md5[13], md5[14], md5[15]];
}

@end
