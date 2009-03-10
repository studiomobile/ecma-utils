#import "FormCell.h"

@implementation FormCell

- (FormFieldDescriptor*)fieldDescriptor {
	return fieldDescriptor;
}

- (void)prepareToReuse {
}

- (void)onFieldDescriptorUpdate {
    [self prepareToReuse];
    
    NSMutableDictionary *options = fieldDescriptor.options;
    for(NSString *key in [options allKeys]) {
//        NSLog(@"value for key '%@' is '%@'", key, [self valueForKey:key]);
        [self setValue:[options valueForKey:key] forKeyPath:key];
    }
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
	[fieldDescriptor release];
	
    [super dealloc];
}


@end
