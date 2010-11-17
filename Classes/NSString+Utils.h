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

- (BOOL)isBefore:(NSString*)other;
- (BOOL)isAfter:(NSString*)other;
- (BOOL)isCaseInsensitiveBefore:(NSString*)other;
- (BOOL)isCaseInsensitiveAfter:(NSString*)other;
    
+ (NSString*)formattedInt:(int)value;

@end
