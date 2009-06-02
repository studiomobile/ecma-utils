#import <UIKit/UIKit.h>

@interface NSString(Utils)

- (BOOL)isEmpty;
- (BOOL)isNotEmpty;
- (NSString *)trimSpaces;
- (NSString *)trim:(NSString*)chars;

- (BOOL)caseInsensitiveStartsWith:(NSString*)prefix;
- (BOOL)startsWith:(NSString*)prefix;
- (BOOL)caseInsensitiveEndsWith:(NSString*)suffix;
- (BOOL)endsWith:(NSString*)suffix;

+ (NSString*)formattedInt:(int)value;

@end
