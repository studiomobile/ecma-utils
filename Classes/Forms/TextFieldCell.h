#import "TitledCell.h"
#import "ForwardingLabel.h"

@interface TextFieldCell : TitledCell<UITextFieldDelegate> {
	UITextField *value;
}
@property (readonly) UITextField *value;

@end
