#import "ImmutableCell.h"

@implementation ImmutableCell

- (id)initWithFrame:(CGRect)frame reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithFrame:frame reuseIdentifier:reuseIdentifier]) {
        self.title.textColor = [UIColor grayColor];
        self.value.textColor = [UIColor grayColor];
    }
	
    return self;
}

@end
