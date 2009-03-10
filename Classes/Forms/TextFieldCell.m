#import "TextFieldCell.h"

@implementation TextFieldCell

@synthesize title;
@synthesize value;

- (UILabel*)createTitleLabel {
    return [[ForwardingLabel alloc] initWithFrame:CGRectZero];
}

- (void)prepareToReuse {
    [super prepareToReuse];
    
    value.autocorrectionType = UITextAutocorrectionTypeNo;
    value.autocapitalizationType = UITextAutocapitalizationTypeNone;
    value.delegate = self;
    value.secureTextEntry = NO;

    ((ForwardingLabel*)title).forwardee = value;
}

- (id)initWithFrame:(CGRect)frame reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithFrame:frame reuseIdentifier:reuseIdentifier]) {
		value = [[UITextField alloc] initWithFrame:CGRectZero];
		[self addSubview:value];
    }
    return self;
}

- (void)onFieldDescriptorUpdate {
    [super onFieldDescriptorUpdate];
    
	self.value.text = self.sourceValue;
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
	self.sourceValue = value.text;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
	self.sourceValue = value.text;
	[value resignFirstResponder];
	return YES;
}

- (void)layoutControls:(CGRect)controlsRect {
	controlsRect.origin.y += 9;
	controlsRect.size.height -= 9;
	value.frame = controlsRect;
}

- (void)dealloc {
	value.delegate = nil;
	[value release];
    [super dealloc];
}


@end
