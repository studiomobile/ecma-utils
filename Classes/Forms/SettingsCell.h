#import "FormCell.h"
#import "ForwardingLabel.h"

@interface SettingsCell : FormCell<UITextFieldDelegate> {
	ForwardingLabel *title;
	UITextField *value;
}
@property (readonly) UILabel *title;
@property (readonly) UITextField *value;

@end
