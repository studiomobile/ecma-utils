#import "FormCell.h"

@implementation FormCell

- (FormFieldDescriptor*)fieldDescriptor {
	return fieldDescriptor;
}

- (id)initWithFrame:(CGRect)frame reuseIdentifier:(NSString *)reuseIdentifier {
    if(self = [super initWithFrame:frame reuseIdentifier:reuseIdentifier]) {
        restoreData = [[NSMutableDictionary alloc] init];
    }
    
    return self;
}

- (void)onFieldDescriptorUpdate {
//    for(NSString *key in restoreData) {
//        NSObject *value = [restoreData valueForKey:key];
//        NSLog(@"restoring '%@' to '%@'", key, value);
//        [self setValue:value forKeyPath:key];
//    }
//    
//    [restoreData removeAllObjects];
//    
//    NSMutableDictionary *options = fieldDescriptor.options;
//    for(NSString *key in [options allKeys]) {
//        [restoreData setValue:[self valueForKeyPath:key] forKey:key];
//        [self setValue:[options valueForKey:key] forKeyPath:key];
//    }
}

- (void)setFieldDescriptor:(FormFieldDescriptor*)desc {
	if(desc != self.fieldDescriptor) {
		[fieldDescriptor release];
		fieldDescriptor = [desc retain];
	}

	[self onFieldDescriptorUpdate];
}

- (id)sourceValue {
	return [self.fieldDescriptor.dataSource valueForKey:self.fieldDescriptor.keyPath];
}

- (void)setSourceValue:(id)newValue {
	return [self.fieldDescriptor.dataSource setValue:newValue forKey:self.fieldDescriptor.keyPath];
}

- (void)dealloc {
    [restoreData release];
	[fieldDescriptor release];
	
    [super dealloc];
}


@end
