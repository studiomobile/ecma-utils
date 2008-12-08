#import "FormCell.h"

@interface StaticFormCell : FormCell {
	UILabel *title;
	UITextField *value;
}
@property (readonly) UILabel *title;
@property (readonly) UITextField *value;

@end
