#import <UIKit/UIKit.h>

typedef enum FormFieldDescriptorType {
    FORM_FIELD_DESCRIPTOR_TEXT_FIELD,
    FORM_FIELD_DESCRIPTOR_TEXT_AREA,
    FORM_FIELD_DESCRIPTOR_COLLECTION,
    FORM_FIELD_DESCRIPTOR_SWITCH,
    FORM_FIELD_DESCRIPTOR_AGREEMENT,
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

@property (readonly) NSMutableDictionary *options;
@end
