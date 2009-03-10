#import <UIKit/UIKit.h>

#import "FormFieldDescriptor.h"

@interface FormCell : UITableViewCell {
	FormFieldDescriptor *fieldDescriptor;
}
@property (readwrite, retain) FormFieldDescriptor *fieldDescriptor;
@property (readwrite, retain) id sourceValue;

- (void)onFieldDescriptorUpdate;
- (void)prepareToReuse;

@end
