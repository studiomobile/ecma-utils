#import "FormCell.h"

@interface TitledCell : FormCell {
	UILabel *title;
    CGFloat titleWidth;
}
@property (readonly) UILabel *title;
@property (nonatomic) CGFloat titleWidth;

- (void)layoutControls:(CGRect)controlsRect;

@end
