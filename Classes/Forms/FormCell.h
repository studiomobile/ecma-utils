#import <UIKit/UIKit.h>

#import "FormFieldDescriptor.h"

@interface FormCell : UITableViewCell {
	FormFieldDescriptor *fieldDescriptor;
    
    NSMutableDictionary *restoreData;
}
@property (readwrite, retain) FormFieldDescriptor *fieldDescriptor;
@property (readwrite, retain) id sourceValue;

- (void)onFieldDescriptorUpdate;

@end
