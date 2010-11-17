#import <UIKit/UIKit.h>

#import "FormFieldDescriptor.h"

@interface FormCell : UITableViewCell {
	FormFieldDescriptor *fieldDescriptor;
    
    NSMutableDictionary *restoreData;
}
@property (readwrite, retain) FormFieldDescriptor *fieldDescriptor;

- (id)initWithFrame:(CGRect)frame reuseIdentifier:(NSString *)reuseIdentifier UNAVAILABLE_ATTRIBUTE; // use initWithReuseIdentifier: instead

- (id)initWithReuseIdentifier:(NSString *)reuseIdentifier;

- (void)onFieldDescriptorUpdate;

@end
