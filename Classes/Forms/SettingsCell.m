#import "SettingsCell.h"

@implementation SettingsCell

@synthesize title;
@synthesize value;

- (id)initWithFrame:(CGRect)frame reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithFrame:frame reuseIdentifier:reuseIdentifier]) {
		title = [[UILabel alloc] initWithFrame:CGRectZero];
		title.font = [UIFont boldSystemFontOfSize:16];
		[self addSubview:title];

		value = [[UITextField alloc] initWithFrame:CGRectZero];
		value.autocorrectionType = UITextAutocorrectionTypeNo;
		value.autocapitalizationType = UITextAutocapitalizationTypeNone;
		value.delegate = self;
		[self addSubview:value];
    }
    return self;
}

- (void)onFieldDescriptorUpdate {
	self.title.text = self.fieldDescriptor.title;
	self.value.text = self.sourceValue;
	self.value.secureTextEntry = self.fieldDescriptor.secure;
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
	self.sourceValue = value.text;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
	self.sourceValue = value.text;
	[value resignFirstResponder];
	return YES;
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
	rightRect.origin.y += 9;
	rightRect.size.height -= 9;
	value.frame = rightRect;
}

- (void)dealloc {
	[title release];
	[value release];
    [super dealloc];
}


@end
