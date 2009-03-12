#import <UIKit/UIKit.h>

#import "FormFieldDescriptor.h"

@interface FormCell : UITableViewCell {
	FormFieldDescriptor *fieldDescriptor;
    
    NSMutableDictionary *restoreData;
}
@property (readwrite, retain) FormFieldDescriptor *fieldDescriptor;

- (void)onFieldDescriptorUpdate;

@end
