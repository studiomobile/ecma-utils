#import "TextFieldCell.h"
#import "NSString+Utils.h"

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
        value.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
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
    
    NSNumber *autocorrectionTypeNumber = [self.fieldDescriptor.options objectForKey:@"value.autocorrectionType"];
    self.value.autocorrectionType = autocorrectionTypeNumber ? [autocorrectionTypeNumber integerValue] : UITextAutocorrectionTypeDefault;
    
    NSNumber *keyboardNumber = [self.fieldDescriptor.options objectForKey:@"value.keyboardType"];
    UIKeyboardType keyboardType = keyboardNumber ? [keyboardNumber integerValue] : UIKeyboardTypeDefault;
    self.value.keyboardType = keyboardType;

    NSNumber *borderStyleNumber = [self.fieldDescriptor.options objectForKey:@"value.borderStyle"];
    self.value.borderStyle = borderStyleNumber ? [borderStyleNumber integerValue] : UITextBorderStyleNone;
    
    self.value.placeholder = [self.fieldDescriptor.options objectForKey:@"value.placeholder"];
    
    NSNumber *textAlignmentNumber = [self.fieldDescriptor.options objectForKey:@"value.textAlignment"];
    self.value.textAlignment = textAlignmentNumber ? [textAlignmentNumber integerValue] : UITextAlignmentLeft;

    NSNumber *clearButtonModeNumber = [self.fieldDescriptor.options objectForKey:@"value.clearButtonMode"];
    self.value.clearButtonMode = clearButtonModeNumber ? [clearButtonModeNumber integerValue] : UITextFieldViewModeNever;
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
    CGFloat fieldHeight = self.value.font.pointSize + 10;
	value.frame = CGRectMake(controlsRect.origin.x, controlsRect.origin.y + (controlsRect.size.height - fieldHeight)/2, controlsRect.size.width, fieldHeight);
}


- (void)dealloc {
	value.delegate = nil;
	[value autorelease];
    [super dealloc];
}


@end
