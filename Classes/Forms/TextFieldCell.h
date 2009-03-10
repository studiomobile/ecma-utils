#import "FormCell.h"
#import "ForwardingLabel.h"

@interface TextFieldCell : FormCell<UITextFieldDelegate> {
	ForwardingLabel *title;
	UITextField *value;
}
@property (readonly) UILabel *title;
@property (readonly) UITextField *value;

@end
