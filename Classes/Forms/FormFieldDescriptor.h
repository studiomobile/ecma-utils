#import <UIKit/UIKit.h>

@interface FormFieldDescriptor : NSObject {
	NSString *title;
	id dataSource;
	NSString *keyPath;
    struct {
		unsigned int custom:1;
        unsigned int secure:1;
        unsigned int editableInplace:1;
        unsigned int selectable:1;
    } _flags;
}

@property (retain) NSString *title;
@property (assign) id dataSource;
@property (retain) NSString *keyPath;
@property (assign) BOOL secure;
@property (assign) BOOL editableInplace;
@property (assign) BOOL selectable;
@property (assign) BOOL custom;

@end
