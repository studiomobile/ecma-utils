#import <UIKit/UIKit.h>
#import "FormFieldDescriptor.h"

#import "FormController.h"

#import "TextFieldCell.h"
#import "StaticFormCell.h"

@interface FormTableController : FormController<UITableViewDataSource> {
}

- (void)enableButton:(BOOL)enable;
- (NSString*)buttonTitle;
- (IBAction)buttonPressed;
- (void)reloadForm;

- (FormFieldDescriptor*)stringFieldWithTitle:(NSString*)title forProperty:(NSString*)keyPath ofObject:(id)object;
- (FormFieldDescriptor*)secureFieldWithTitle:(NSString*)title forProperty:(NSString*)keyPath ofObject:(id)object;
- (FormFieldDescriptor*)textFieldWithTitle:(NSString*)title forProperty:(NSString*)keyPath ofObject:(id)object;
- (FormFieldDescriptor*)collectionFieldWithTitle:(NSString*)title forProperty:(NSString*)keyPath ofObject:(id)object;
- (FormFieldDescriptor*)customFieldWithTitle:(NSString*)title forProperty:(NSString*)keyPath ofObject:(id)object;

- (StaticFormCell*)staticCellWithDescriptor:(FormFieldDescriptor*)desc;
- (StaticFormCell*)immutableCellWithDescriptor:(FormFieldDescriptor*)desc;
- (StaticFormCell*)disclosingCellWithDescriptor:(FormFieldDescriptor*)desc;
- (TextFieldCell*)textFieldCellWithDescriptor:(FormFieldDescriptor*)desc;

@end
