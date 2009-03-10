#import "FormCell.h"

@interface StaticFormCell : FormCell {
	UILabel *title;
	UILabel *value;
}
@property (readonly) UILabel *title;
@property (readonly) UILabel *value;

@end
