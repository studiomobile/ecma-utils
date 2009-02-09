#import "CollectionWindow.h"

@implementation CollectionWindow

- (id)initWithWindowSize:(NSUInteger)s {
    if(s == 0) {
        [NSException raise:@"NSArgumentException" format:@"Size can not be 0"];
    }
    if(self = [super init]) {
        storage = [[NSMutableArray alloc] initWithCapacity:size];
        size = s;
    }
    return self;
}

- (void)dealloc {
    [storage release];
    [super dealloc];
}

- (void)push:(id)val {
    [storage addObject:val];
    if([storage count] > size) {
        [storage removeObjectAtIndex:0];
    }
}

- (NSArray*)content {
    return [NSArray arrayWithArray:storage];
}

- (void)clean {
    [storage removeAllObjects];
}

- (id)first {
    return [storage objectAtIndex:0];
}

- (id)last {
    return [storage lastObject];
}

@end
