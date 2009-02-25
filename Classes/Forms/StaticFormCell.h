#import "FormCell.h"
#import "ForwardingLabel.h"

@interface StaticFormCell : FormCell {
	ForwardingLabel *title;
	UITextField *value;
}
@property (readonly) UILabel *title;
@property (readonly) UITextField *value;

@end
