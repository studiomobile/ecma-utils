#import "FormFieldDescriptor.h"

@implementation FormFieldDescriptor

@synthesize title;
@synthesize dataSource;
@synthesize keyPath;

- (BOOL)secure {
	return _flags.secure != 0;
}

- (void)setSecure:(BOOL)secure {
	_flags.secure = secure ? 1 : 0;
}

- (BOOL)editableInplace {
	return _flags.editableInplace != 0;
}

- (void)setEditableInplace:(BOOL)editable {
	_flags.editableInplace = editable ? 1 : 0;
}

- (BOOL)selectable {
	return _flags.selectable != 0;
}

- (void)setSelectable:(BOOL)selectable {
	_flags.selectable = selectable ? 1 : 0;
}

- (BOOL)custom {
	return _flags.custom != 0;
}

- (void)setCustom:(BOOL)custom {
	_flags.custom = custom ? 1 : 0;
}

- (void)dealloc {
	NSLog(@"FormFieldDescriptor dealloc");
	
	[super dealloc];
}
@end
