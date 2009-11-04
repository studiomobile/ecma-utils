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
    NSNumber *accessoryTypeNumber = [self.fieldDescriptor.options objectForKey:@"accessoryType"];
    self.accessoryType = accessoryTypeNumber ? [accessoryTypeNumber integerValue] : UITableViewCellAccessoryNone;

    NSNumber *selectionStyleNumber = [self.fieldDescriptor.options objectForKey:@"selectionStyle"];
    self.selectionStyle = selectionStyleNumber ? [selectionStyleNumber integerValue] : UITableViewCellSelectionStyleBlue;

    self.accessoryView = [self.fieldDescriptor.options objectForKey:@"accessoryView"];
}


- (void)setFieldDescriptor:(FormFieldDescriptor*)desc {
	if(desc != self.fieldDescriptor) {
		[fieldDescriptor release];
		fieldDescriptor = [desc retain];
	}

	[self onFieldDescriptorUpdate];
}


- (void)dealloc {
    [restoreData release];
	[fieldDescriptor release];
	
    [super dealloc];
}


@end
