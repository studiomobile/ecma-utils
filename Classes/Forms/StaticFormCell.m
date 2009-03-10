#import "StaticFormCell.h"


@implementation StaticFormCell

@synthesize title;
@synthesize value;

- (void)prepareToReuse {
    [super prepareToReuse];
    
    value.backgroundColor = [UIColor clearColor];
}

- (id)initWithFrame:(CGRect)frame reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithFrame:frame reuseIdentifier:reuseIdentifier]) {
		value = [[UILabel alloc] initWithFrame:CGRectZero];
		[self addSubview:value];
    }

    return self;
}

- (void)onFieldDescriptorUpdate {
    [super onFieldDescriptorUpdate];
    
	self.value.text = [self.sourceValue description];
}

- (void)layoutControls:(CGRect)controlsRect {
	value.frame = controlsRect;
}

- (void)dealloc {
	[value release];
    [super dealloc];
}

@end
