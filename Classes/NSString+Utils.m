#import "NSString+Utils.h"


@implementation NSString(Utils)


- (BOOL)isEmpty {
	return [[self stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"\n\r\t "]] isEqualToString:@""];
}


- (BOOL)isNotEmpty {
	return ![self isEmpty];
}


- (NSString *)trimSpaces {
	return [self stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"\n\r\t "]];
}


- (NSString *)trim:(NSString*)chars {
	return [self stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:chars]];
}


- (BOOL)containsSubstring:(NSString*)substring location:(NSInteger)location caseSensitive:(BOOL)caseSensitive {
    if(!substring.length) return YES;
    
    NSRange searchRange = NSMakeRange(location, substring.length);
    NSRange foundRange = [self rangeOfString:substring
                                     options:caseSensitive ? 0 : NSCaseInsensitiveSearch
                                       range:searchRange];
    
    return (foundRange.location != NSNotFound);
}


- (BOOL)caseInsensitiveStartsWith:(NSString*)prefix {
    return [self containsSubstring:prefix location:0 caseSensitive:NO];
}


- (BOOL)startsWith:(NSString*)prefix {
    return [self containsSubstring:prefix location:0 caseSensitive:YES];
}


- (BOOL)caseInsensitiveEndsWith:(NSString*)suffix {
    return [self containsSubstring:suffix location:self.length - suffix.length caseSensitive:NO];
}


- (BOOL)endsWith:(NSString*)suffix {
    return [self containsSubstring:suffix location:self.length - suffix.length caseSensitive:YES];
}


- (BOOL)isBefore:(NSString*)other {
    return [self compare:other] < 0;
}


- (BOOL)isAfter:(NSString*)other {
    return [self compare:other] > 0;
}


- (BOOL)isCaseInsensitiveBefore:(NSString*)other {
    return [self caseInsensitiveCompare:other] < 0;
}


- (BOOL)isCaseInsensitiveAfter:(NSString*)other {
    return [self caseInsensitiveCompare:other] > 0;
}


+ (NSString *)formattedInt:(int)value {
    NSMutableString *formatted = [NSMutableString stringWithFormat:@"%d", value];
    int pos = 3;
    while (formatted.length > pos) {
        [formatted insertString:@"," atIndex:formatted.length - pos];
        pos += 4;
    }
    return formatted;
}


@end
