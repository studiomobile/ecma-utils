#import "DateTimeCell.h"

@implementation DateTimeCell

- (id)initWithReuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithReuseIdentifier:reuseIdentifier]) {
		formatter = [[NSDateFormatter alloc] init];
        self.value.enabled = NO;
    }
    
    return self;
}

- (void)onFieldDescriptorUpdate {
    [super onFieldDescriptorUpdate];

    NSString *dateFormat = [self.fieldDescriptor.options valueForKey:@"formatter.dateFormat"];
    formatter.dateFormat = dateFormat ? dateFormat : @"yyyy-MM-dd hh:mm";
	self.value.text = [formatter stringFromDate:self.fieldDescriptor.value];
}

- (void)dealloc {
	[formatter release];
    [super dealloc];
}
@end
