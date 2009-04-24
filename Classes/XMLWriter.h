#import <Foundation/Foundation.h>

@interface XMLWriter : NSObject {
    NSString *indentation;
    NSString *lineBreak;
    
    NSMutableString *resultMutable;
    NSMutableArray *tagStack;
    NSMutableArray *indentsCache;
    NSInteger indentationLevel;
}
@property (readonly) NSString* result;

+ (NSString*)cdata:(NSString*)content;

- (id)initWithIndentation:(NSString*)indent lineBreak:(NSString*)br;

- (void)instruct;

- (void)tag:(NSString*)name content:(NSString*)content attributes:(NSDictionary*)attributes;
- (void)tag:(NSString*)name content:(NSString*)content;
- (void)openTag:(NSString*)name attributes:(NSDictionary*)attributes;
- (void)openTag:(NSString*)name;
- (void)closeTag;

- (void)comment:(NSString*)comment;
@end
