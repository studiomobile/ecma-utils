#import <UIKit/UIKit.h>
#import "FormFieldDescriptor.h"
#import "SegmentedControlCell.h"

#import "FormController.h"

#import "FormDatePickerView.h"
#import "TextFieldCell.h"
#import "StaticFormCell.h"
#import "SwitchCell.h"
#import "AgreementCell.h"
#import "DateTimeCell.h"
#import "SelectionController.h"

@interface FormTableController : FormController<UITableViewDataSource, FormDatePickerViewDelegate, SelectionControllerDelegate> {
    NSIndexPath *currentIndexPath;
    
    FormDatePickerView *datePickerView;
    BOOL datePickerVisible;
}
@property (retain) NSIndexPath *currentIndexPath;
@property (readonly) FormDatePickerView *datePickerView;
@property (readonly) FormCell *currentCell;

- (void)enableButton:(BOOL)enable;
- (NSString*)buttonTitle:(NSInteger)buttonNumber;
- (UITableViewCell*)buttonByNumber:(NSInteger)buttonNumber;
- (IBAction)buttonPressed:(NSInteger)buttonNumber;
- (void)reloadForm;
- (void)hideDatePicker;
- (void)hideControls;



- (FormFieldDescriptor*)descriptorForField:(NSIndexPath*)indexPath;

- (FormFieldDescriptor*)fieldWithTitle:(NSString*)title forProperty:(NSString*)keyPath ofObject:(id)object type:(FormFieldDescriptorType)type;

- (FormFieldDescriptor*)textFieldWithTitle:(NSString*)title forProperty:(NSString*)keyPath ofObject:(id)object;
- (FormFieldDescriptor*)numTextFieldWithTitle:(NSString *)title forProperty:(NSString *)keyPath ofObject:(id)object;
- (FormFieldDescriptor*)sentenceCapitalizationTextFieldWithTitle:(NSString *)title forProperty:(NSString *)keyPath ofObject:(id)object;
- (FormFieldDescriptor*)emailFieldWithTitle:(NSString*)title forProperty:(NSString*)keyPath ofObject:(id)object;
- (FormFieldDescriptor*)secureFieldWithTitle:(NSString*)title forProperty:(NSString*)keyPath ofObject:(id)object;
- (FormFieldDescriptor*)textEditFieldWithTitle:(NSString*)title forProperty:(NSString*)keyPath ofObject:(id)object;
- (FormFieldDescriptor*)collectionFieldWithTitle:(NSString*)title forProperty:(NSString*)keyPath ofObject:(id)object;
- (FormFieldDescriptor*)switchFieldWithTitle:(NSString*)title forProperty:(NSString*)keyPath ofObject:(id)object;
- (FormFieldDescriptor*)segmentedControlFieldWithTitle:(NSString*)title forProperty:(NSString*)keyPath ofObject:(id)object;
- (FormFieldDescriptor*)agreementFieldWithTitle:(NSString*)title forProperty:(NSString*)keyPath ofObject:(id)object;
- (FormFieldDescriptor*)dateTimeFieldWithTitle:(NSString*)title forProperty:(NSString*)keyPath ofObject:(id)object;
- (FormFieldDescriptor*)dateFieldWithTitle:(NSString*)title forProperty:(NSString*)keyPath ofObject:(id)object;
- (FormFieldDescriptor*)timeFieldWithTitle:(NSString*)title forProperty:(NSString*)keyPath ofObject:(id)object;
- (FormFieldDescriptor*)customFieldWithTitle:(NSString*)title forProperty:(NSString*)keyPath ofObject:(id)object;

- (FormCell*)formCellWithClass:(Class)klass reuseIdentifier:(NSString*)reuseIdentifier descriptor:(FormFieldDescriptor*)desc;
- (StaticFormCell*)staticCellWithDescriptor:(FormFieldDescriptor*)desc;
- (StaticFormCell*)immutableCellWithDescriptor:(FormFieldDescriptor*)desc;
- (StaticFormCell*)disclosingCellWithDescriptor:(FormFieldDescriptor*)desc;
- (TextFieldCell*)textFieldCellWithDescriptor:(FormFieldDescriptor*)desc;
- (SwitchCell*)switchFieldCellWithDescriptor:(FormFieldDescriptor*)desc;
- (SegmentedControlCell*)segmentedFieldCellWithDescriptor:(FormFieldDescriptor*)desc;
- (AgreementCell*)agreementFieldCellWithDescriptor:(FormFieldDescriptor*)desc;
- (DateTimeCell*)dateTimeFieldCellWithDescriptor:(FormFieldDescriptor*)desc;

- (NSString*)selectControllerTitleForDescriptor:(FormFieldDescriptor*)desc indexPath:(NSIndexPath*)indexPath;
- (NSString*)textEditControllerTitleForDescriptor:(FormFieldDescriptor*)desc indexPath:(NSIndexPath*)indexPath;
- (NSString*)agreementControllerTitleForDescriptor:(FormFieldDescriptor*)desc indexPath:(NSIndexPath*)indexPath;
    
@end
