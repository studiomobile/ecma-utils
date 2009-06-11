#import "TextFieldCell.h"

@implementation TextFieldCell

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
    
	self.value.text = [self.fieldDescriptor.value description];
	self.value.secureTextEntry = [[self.fieldDescriptor.options objectForKey:@"value.secureTextEntry"] boolValue];
    
    NSNumber *autocapitalizationTypeNumber = [self.fieldDescriptor.options objectForKey:@"value.autocapitalizationType"];
    self.value.autocapitalizationType = autocapitalizationTypeNumber ? [autocapitalizationTypeNumber integerValue] : UITextAutocapitalizationTypeNone;
    
    NSNumber *autocorrectionTypeNumber = [self.fieldDescriptor.options objectForKey:@"value.autoccorrectionType"];
    self.value.autocorrectionType = autocorrectionTypeNumber ? [autocorrectionTypeNumber integerValue] : UITextAutocorrectionTypeDefault;
    
    NSNumber *keyboardNumber = [self.fieldDescriptor.options objectForKey:@"value.keyboardType"];
    UIKeyboardType keyboardType = keyboardNumber ? [keyboardNumber integerValue] : UIKeyboardTypeDefault;
    self.value.keyboardType = keyboardType;

    NSNumber *borderStyleNumber = [self.fieldDescriptor.options objectForKey:@"value.borderStyle"];
    UIKeyboardType borderStyle = borderStyleNumber ? [borderStyleNumber integerValue] : UITextBorderStyleNone;
    self.value.borderStyle = borderStyle;
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
    // TODO cleanup
    if(self.value.borderStyle == UITextBorderStyleNone) {
    	controlsRect.origin.y += 6;
    	controlsRect.size.height -= 6;
    }
    
    CGFloat fieldHeight = self.value.font.pointSize + 10;
	value.frame = CGRectMake(controlsRect.origin.x, controlsRect.origin.y + (controlsRect.size.height - fieldHeight)/2, controlsRect.size.width, fieldHeight);
}

- (void)dealloc {
	value.delegate = nil;
	[value release];
    [super dealloc];
}


@end
