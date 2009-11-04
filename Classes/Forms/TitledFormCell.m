#import "TitledFormCell.h"

@implementation TitledFormCell

@synthesize title;
@synthesize titleWidth;

- (UILabel*)createTitleLabel {
    return [[UILabel alloc] initWithFrame:CGRectZero];
}


- (id)initWithFrame:(CGRect)frame reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithFrame:frame reuseIdentifier:reuseIdentifier]) {
		title = [self createTitleLabel];
        title.font = [UIFont boldSystemFontOfSize:16];
        title.backgroundColor = [UIColor clearColor];
		[self.contentView addSubview:title];
    }
    
    return self;
}


- (void)onFieldDescriptorUpdate {
    [super onFieldDescriptorUpdate];
    
    NSNumber *titleWidthNumber = [self.fieldDescriptor.options objectForKey:@"title.width"];
    titleWidth = titleWidthNumber ? [titleWidthNumber floatValue] : 100.0;
    
    UIColor *titleColor = [self.fieldDescriptor.options objectForKey:@"title.textColor"];
    self.title.textColor = titleColor ? titleColor : [UIColor blackColor];
    
	self.title.text = self.fieldDescriptor.title;

    NSNumber *titleFloatingWidthNumber = [self.fieldDescriptor.options objectForKey:@"title.floatingWidth"];
    if(titleFloatingWidthNumber && [titleFloatingWidthNumber boolValue]) {
        CGSize titleSize = [self.title.text sizeWithFont:self.title.font constrainedToSize:self.contentView.bounds.size];
        titleWidth = titleSize.width + 5;
    }
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
}


- (void)layoutControls:(CGRect)controlsRect {
}


- (void)layoutSubviews {
	[super layoutSubviews];
	CGRect bounds = self.contentView.bounds;
	bounds = CGRectInset(bounds, 10, 2);
	
	CGRect titleRect;
	CGRect controlsRect = bounds;
	CGRectDivide(controlsRect, &titleRect, &controlsRect, fmax(0, fmin(titleWidth, controlsRect.size.width)), CGRectMinXEdge);
	
	title.frame = titleRect;
    [self layoutControls:controlsRect];
}


- (void)dealloc {
	[title release];	
    [super dealloc];
}


@end
