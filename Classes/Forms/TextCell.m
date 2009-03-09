#import "TextCell.h"

@implementation TextCell

- (id)initWithFrame:(CGRect)frame reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithFrame:frame reuseIdentifier:reuseIdentifier]) {
		self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
	
    return self;
}

- (void)dealloc {
    [super dealloc];
}


@end
