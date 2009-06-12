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

- (id)value {
	return [self.dataSource valueForKey:self.keyPath];
}

- (void)setValue:(id)newValue {
	return [self.dataSource setValue:newValue forKey:self.keyPath];
}

- (void)dealloc {

    [options release];
    [super dealloc];
}
@end
