#import "TitledCell.h"
#import "ForwardingLabel.h"

@interface TextFieldCell : TitledCell<UITextFieldDelegate> {
	UITextField *value;
}
@property (readwrite, retain) UITextField *value;

@end
