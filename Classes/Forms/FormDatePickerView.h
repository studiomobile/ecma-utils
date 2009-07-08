#import <UIKit/UIKit.h>
#import "FormFieldDescriptor.h"

@class FormDatePickerView;
@protocol FormDatePickerViewDelegate

- (void)formDatePickerViewDateChanged:(FormDatePickerView*)datePickerView;
- (void)formDatePickerViewDone:(FormDatePickerView*)datePickerView;

@end

@interface FormDatePickerView : UIView {
    id<FormDatePickerViewDelegate> delegate;
    UIToolbar *toolbar;
    UIDatePicker *datePicker;
    UIBarButtonItem *labelItem;
    
    NSDateFormatter *labelDateFormatter;
    
    NSDate *date;
}
@property (assign) id<FormDatePickerViewDelegate> delegate;
@property (readonly) NSDate *date;

- (id)initWithWidth:(CGFloat)width;

- (void)reconfigureWithDescriptor:(FormFieldDescriptor*)desc;
@end
