#import <Foundation/Foundation.h>

@interface CollectionWindow : NSObject {
    NSUInteger size;
    NSMutableArray *storage;
}

- (id)initWithWindowSize:(NSUInteger)size;
- (void)push:(id)val;
- (NSArray*)content;
- (id)first;
- (id)last;

@end
