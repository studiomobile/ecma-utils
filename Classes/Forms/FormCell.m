#import "FormCell.h"


@implementation FormCell

- (FormFieldDescriptor*)fieldDescriptor {
	return fieldDescriptor;
}

- (void)onFieldDescriptorUpdate {
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
