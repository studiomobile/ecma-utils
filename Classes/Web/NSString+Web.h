#import <Foundation/Foundation.h>

@interface NSString (Web)

- (NSURL*)toUrl;
- (NSURL*)toFileUrl;

- (NSString*)urlEncode:(NSString*)additionalCharacters;
- (NSString*)urlEncode;

- (NSString*)urlDecode;
- (NSString*)urlDecode:(NSString*)additionalCharacters;

@end
