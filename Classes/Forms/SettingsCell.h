#import "FormCell.h"

@interface SettingsCell : FormCell<UITextFieldDelegate> {
	UILabel *title;
	UITextField *value;
}
@property (readonly) UILabel *title;
@property (readonly) UITextField *value;

@end
