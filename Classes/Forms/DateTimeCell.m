#import "DateTimeCell.h"

@implementation DateTimeCell

- (id)initWithFrame:(CGRect)frame reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithFrame:frame reuseIdentifier:reuseIdentifier]) {
		formatter = [[NSDateFormatter alloc] init];
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
