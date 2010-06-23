#import "AgreementCell.h"

@implementation AgreementCell

- (id)initWithReuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithReuseIdentifier:reuseIdentifier]) {
        self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;

        self.value.font = [self.value.font fontWithSize:14];
        self.value.textAlignment = UITextAlignmentRight;
    }
    
    return self;
}

- (void)layoutSubviews {
	[super layoutSubviews];

	CGRect bounds = self.contentView.bounds;
	bounds = CGRectInset(bounds, 10, 2);
	
	CGRect titleRect;
	CGRect controlsRect;
	CGRectDivide(bounds, &controlsRect, &titleRect, 100, CGRectMaxXEdge);
	
	title.frame = titleRect;
    [self layoutControls:controlsRect];
}

- (void)onFieldDescriptorUpdate {
    [super onFieldDescriptorUpdate];

    NSString *acceptedText = [self.fieldDescriptor.options objectForKey:@"acceptedText"];
    acceptedText = acceptedText ? acceptedText : @"Accepted";

    NSString *notAcceptedText = [self.fieldDescriptor.options objectForKey:@"notAcceptedText"];
    notAcceptedText = notAcceptedText ? notAcceptedText : @"Not accepted";

    self.value.text = [self.fieldDescriptor.value boolValue] ? acceptedText : notAcceptedText;
	self.value.textColor = [self.fieldDescriptor.value boolValue] 
    ? [UIColor colorWithRed:80/255. green:160/255. blue:15/255. alpha:1] 
    : [UIColor colorWithRed:240/255. green:50/255. blue:50/255. alpha:1];
}

@end
