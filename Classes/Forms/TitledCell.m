#import "TitledCell.h"

@implementation TitledCell

@synthesize title;

- (UILabel*)createTitleLabel {
    return [[UILabel alloc] initWithFrame:CGRectZero];
}

- (void)prepareToReuse {
    [super prepareToReuse];
    
    title.font = [UIFont boldSystemFontOfSize:16];
    title.backgroundColor = [UIColor clearColor];
    //		title.userInteractionEnabled = YES;
}

- (id)initWithFrame:(CGRect)frame reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithFrame:frame reuseIdentifier:reuseIdentifier]) {
		title = [self createTitleLabel];
        
		[self addSubview:title];
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
	bounds = CGRectInset(bounds, 20, 2);
	
	CGRect leftRect;
	CGRect rightRect;
	CGRectDivide(bounds, &leftRect, &rightRect, 100, CGRectMinXEdge);
	
	title.frame = leftRect;
    [self layoutControls:rightRect];
}

- (void)dealloc {
	[title release];	
    [super dealloc];
}


@end
