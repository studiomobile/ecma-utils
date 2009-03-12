#import "TextFieldCell.h"

@implementation TextFieldCell

@synthesize title;
@synthesize value;

- (UILabel*)createTitleLabel {
    return [[ForwardingLabel alloc] initWithFrame:CGRectZero];
}

- (id)initWithFrame:(CGRect)frame reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithFrame:frame reuseIdentifier:reuseIdentifier]) {
		value = [[UITextField alloc] initWithFrame:CGRectZero];
        value.autocorrectionType = UITextAutocorrectionTypeNo;
        value.autocapitalizationType = UITextAutocapitalizationTypeNone;
        value.delegate = self;
        value.secureTextEntry = NO;
//        value.textAlignment = UITextAlignmentRight;
		[self.contentView addSubview:value];

        ((ForwardingLabel*)title).forwardee = value;
    }
    return self;
}

- (void)edit {
    [self.value becomeFirstResponder];
}

- (void)onFieldDescriptorUpdate {
    [super onFieldDescriptorUpdate];
    
	self.value.text = self.fieldDescriptor.value;
	self.value.secureTextEntry = [[self.fieldDescriptor.options objectForKey:@"value.secureTextEntry"] boolValue];
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
	self.fieldDescriptor.value = value.text;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
	self.fieldDescriptor.value = value.text;
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
