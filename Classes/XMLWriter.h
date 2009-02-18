#import <Foundation/Foundation.h>

@interface XMLWriter : NSObject {
    NSString *indentation;
    NSString *lineBreak;
    
    NSMutableString *result;
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
- (void)push:(NSString*)name attributes:(NSDictionary*)attributes;
- (void)push:(NSString*)name;
- (void)pop;

- (void)comment:(NSString*)comment;
@end
