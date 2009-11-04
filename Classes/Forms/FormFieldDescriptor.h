#import <UIKit/UIKit.h>

/*	used options:
		
		collection
		collectionInvocation
		customInvocation
		
		formatter.dateFormat
		datePicker.datePickerMode
		value.secureTextEntry
		value.keyboardType
		value.secureTextEntry
*/

typedef enum FormFieldDescriptorType {
    FORM_FIELD_DESCRIPTOR_TEXT_FIELD,
    FORM_FIELD_DESCRIPTOR_TEXT_AREA,
    FORM_FIELD_DESCRIPTOR_COLLECTION,
    FORM_FIELD_DESCRIPTOR_SWITCH,
    FORM_FIELD_DESCRIPTOR_SEGMENTED,
    FORM_FIELD_DESCRIPTOR_AGREEMENT,
    FORM_FIELD_DESCRIPTOR_DATETIME,
    FORM_FIELD_DESCRIPTOR_CUSTOM
} FormFieldDescriptorType;

@interface FormFieldDescriptor : NSObject {
    FormFieldDescriptorType type;

    NSMutableDictionary *options;
   
	NSString *title;
	id dataSource;
	NSString *keyPath;
}

@property (assign) FormFieldDescriptorType type;
@property (retain) NSString *title;
@property (assign) id dataSource;
@property (retain) NSString *keyPath;
@property (readwrite, assign) id value;

@property (readonly) NSMutableDictionary *options;

- (NSArray*)getCollection;

@end
