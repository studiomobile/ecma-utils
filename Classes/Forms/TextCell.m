#import "TextCell.h"

@implementation TextCell

- (id)initWithFrame:(CGRect)frame reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithFrame:frame reuseIdentifier:reuseIdentifier]) {
        self.title.textColor = [UIColor blackColor];
        self.value.textColor = [UIColor blackColor];
		self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
	
    return self;
}

- (void)dealloc {
    [super dealloc];
}


@end
