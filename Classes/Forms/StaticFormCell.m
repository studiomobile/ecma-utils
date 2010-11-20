#import "StaticFormCell.h"


@implementation StaticFormCell

@synthesize value;

- (id)initWithReuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithReuseIdentifier:reuseIdentifier]) {
		value = [[UILabel alloc] initWithFrame:CGRectZero];
        value.backgroundColor = [UIColor clearColor];
        value.adjustsFontSizeToFitWidth = YES;
		[self.contentView addSubview:value];
    }

    return self;
}


- (void)onFieldDescriptorUpdate {
    [super onFieldDescriptorUpdate];
    
	self.value.text = [self.fieldDescriptor.value description];

    UIColor *valueColor = [self.fieldDescriptor.options objectForKey:@"value.textColor"];
    self.value.textColor = valueColor ? valueColor : [UIColor blackColor];
    
    UIFont *valueFont = [self.fieldDescriptor.options objectForKey:@"value.font"];
    self.value.font = valueFont ? valueFont : self.value.font;
    
    NSNumber *textAlignmentNumber = [self.fieldDescriptor.options objectForKey:@"value.textAlignment"];
    self.value.textAlignment = textAlignmentNumber ? [textAlignmentNumber integerValue] : UITextAlignmentLeft;
}


- (void)layoutControls:(CGRect)controlsRect {
	value.frame = controlsRect;
}


- (void)dealloc {
	[value release];
    [super dealloc];
}

@end
