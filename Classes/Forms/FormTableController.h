#import <UIKit/UIKit.h>
#import "FormFieldDescriptor.h"

#import "FormController.h"

#import "ImmutableCell.h"
#import "TextFieldCell.h"
#import "TextCell.h"

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

- (ImmutableCell*)immutableCellWithDescriptor:(FormFieldDescriptor*)desc;
- (StaticFormCell*)staticCellWithDescriptor:(FormFieldDescriptor*)desc;
- (TextFieldCell*)settingsCellWithDescriptor:(FormFieldDescriptor*)desc;
- (TextCell*)textCellWithDescriptor:(FormFieldDescriptor*)desc;

@end
