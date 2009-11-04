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


- (NSArray*)getCollection {
    NSArray *collection = [self.options valueForKey:@"collection"];
    if(collection) {
        return collection;
    }
    
	NSInvocation *invocation = [self.options valueForKey:@"collectionInvocation"];
	if(invocation){
		[invocation invoke];
		[invocation getReturnValue:&collection];
		if(collection) return collection;
	}
    
    return nil;
}


- (void)dealloc {

    [options release];
    [super dealloc];
}
@end
