#import "TitledCell.h"
#import "ForwardingLabel.h"

@interface TextFieldCell : TitledCell<UITextFieldDelegate> {
	UITextField *value;
}
@property (readonly) UITextField *value;

- (void)edit;
@end
