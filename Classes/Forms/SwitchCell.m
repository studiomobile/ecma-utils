#import "SwitchCell.h"

@implementation SwitchCell

@synthesize switcher;

- (id)initWithReuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithReuseIdentifier:reuseIdentifier]) {
		switcher = [[UISwitch alloc] initWithFrame:CGRectZero];
        [switcher addTarget:self action:@selector(switched) forControlEvents:UIControlEventValueChanged];
		[self.contentView addSubview:switcher];
        
        self.titleWidth = 175;
    }
    return self;
}


- (void)dealloc {
	[switcher release];	
    [super dealloc];
}


- (void)layoutControls:(CGRect)rect {
    switcher.frame = CGRectMake(rect.origin.x + rect.size.width - switcher.frame.size.width, rect.origin.y + (rect.size.height - switcher.frame.size.height)/2.0, switcher.frame.size.width, switcher.frame.size.height);
}


- (void)onFieldDescriptorUpdate {
    [super onFieldDescriptorUpdate];
    
	self.switcher.on = [self.fieldDescriptor.value boolValue];
}


- (void)switched {
    self.fieldDescriptor.value = [NSNumber numberWithBool:switcher.on];
}

@end
