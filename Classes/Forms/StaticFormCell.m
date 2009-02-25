#import "StaticFormCell.h"


@implementation StaticFormCell

@synthesize title;
@synthesize value;

- (id)initWithFrame:(CGRect)frame reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithFrame:frame reuseIdentifier:reuseIdentifier]) {
		title = [[ForwardingLabel alloc] initWithFrame:CGRectZero];
		title.font = [UIFont boldSystemFontOfSize:16];
        title.textColor = [UIColor grayColor];
		[self addSubview:title];
		
		value = [[UILabel alloc] initWithFrame:CGRectZero];
        value.textColor = [UIColor grayColor];
		
		title.forwardee = value;
		
		[self addSubview:value];
    }

    return self;
}

- (void)onFieldDescriptorUpdate {
	self.title.text = self.fieldDescriptor.title;
	self.value.text = [self.sourceValue description];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
}

- (void)layoutSubviews {
	[super layoutSubviews];
	CGRect bounds = self.contentView.bounds;
	bounds = CGRectInset(bounds, 20, 2);
	
	CGRect leftRect;
	CGRect rightRect;
	CGRectDivide(bounds, &leftRect, &rightRect, 100, CGRectMinXEdge);
	
	title.frame = leftRect;
	value.frame = rightRect;
}

- (void)dealloc {
	[title release];
	[value release];
    [super dealloc];
}

@end
