#import "AgreementCell.h"

@implementation AgreementCell

- (id)initWithFrame:(CGRect)frame reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithFrame:frame reuseIdentifier:reuseIdentifier]) {
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
    
	self.value.text = [self.sourceValue boolValue] ? @"Accepted" :  @"Not accepted";
	self.value.textColor = [self.sourceValue boolValue] 
    ? [UIColor colorWithRed:80/255. green:160/255. blue:15/255. alpha:1] 
    : [UIColor colorWithRed:240/255. green:50/255. blue:50/255. alpha:1];
}

@end
