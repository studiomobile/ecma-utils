#import <UIKit/UIKit.h>
#import "FormFieldDescriptor.h"

#import "FormController.h"

#import "TextFieldCell.h"
#import "StaticFormCell.h"
#import "SwitchCell.h"
#import "AgreementCell.h"
#import "DateTimeCell.h"

@interface FormTableController : FormController<UITableViewDataSource> {
    NSIndexPath *currentIndexPath;
    
    UIView *datePickerView;
    UIDatePicker *datePicker;
    BOOL datePickerVisible;
}
@property (retain) NSIndexPath *currentIndexPath;
@property (readonly) UIView *datePickerView;
@property (readonly) UIDatePicker *datePicker;
@property (readonly) FormCell *currentCell;

- (void)enableButton:(BOOL)enable;
- (NSString*)buttonTitle;
- (IBAction)buttonPressed;
- (void)reloadForm;
- (void)hideDatePicker;
- (void)hideControls;

- (FormFieldDescriptor*)stringFieldWithTitle:(NSString*)title forProperty:(NSString*)keyPath ofObject:(id)object;
- (FormFieldDescriptor*)secureFieldWithTitle:(NSString*)title forProperty:(NSString*)keyPath ofObject:(id)object;
- (FormFieldDescriptor*)textFieldWithTitle:(NSString*)title forProperty:(NSString*)keyPath ofObject:(id)object;
- (FormFieldDescriptor*)collectionFieldWithTitle:(NSString*)title forProperty:(NSString*)keyPath ofObject:(id)object;
- (FormFieldDescriptor*)switchFieldWithTitle:(NSString*)title forProperty:(NSString*)keyPath ofObject:(id)object;
- (FormFieldDescriptor*)agreementFieldWithTitle:(NSString*)title forProperty:(NSString*)keyPath ofObject:(id)object;
- (FormFieldDescriptor*)dateTimeFieldWithTitle:(NSString*)title forProperty:(NSString*)keyPath ofObject:(id)object;
- (FormFieldDescriptor*)customFieldWithTitle:(NSString*)title forProperty:(NSString*)keyPath ofObject:(id)object;

- (StaticFormCell*)staticCellWithDescriptor:(FormFieldDescriptor*)desc;
- (StaticFormCell*)immutableCellWithDescriptor:(FormFieldDescriptor*)desc;
- (StaticFormCell*)disclosingCellWithDescriptor:(FormFieldDescriptor*)desc;
- (TextFieldCell*)textFieldCellWithDescriptor:(FormFieldDescriptor*)desc;
- (SwitchCell*)switchFieldCellWithDescriptor:(FormFieldDescriptor*)desc;
- (AgreementCell*)agreementFieldCellWithDescriptor:(FormFieldDescriptor*)desc;
- (DateTimeCell*)dateTimeFieldCellWithDescriptor:(FormFieldDescriptor*)desc;

@end
