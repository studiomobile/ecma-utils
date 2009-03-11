#import "TitledCell.h"

@implementation TitledCell

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
        
        titleWidth = 100;
    }
    
    return self;
}

- (void)onFieldDescriptorUpdate {
    [super onFieldDescriptorUpdate];
    
	self.title.text = self.fieldDescriptor.title;
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
//	CGRectDivide(bounds, &titleRect, &controlsRect, self.xMargin, CGRectMinXEdge);
	CGRectDivide(controlsRect, &titleRect, &controlsRect, titleWidth, CGRectMinXEdge);
	
	title.frame = titleRect;
//    self.contentView.backgroundColor = [UIColor greenColor];
    [self layoutControls:controlsRect];
}

- (void)dealloc {
	[title release];	
    [super dealloc];
}


@end
