#import "FormFieldDescriptor.h"

@implementation FormFieldDescriptor

@synthesize type;
@synthesize title;
@synthesize dataSource;
@synthesize keyPath;
@synthesize options;

- (id)init {
    if(self = [super init]) {
        options = [[NSMutableDictionary alloc] init];
    }
    
    return self;
}

- (void)dealloc {
    [options release];
    [super dealloc];
}
@end
