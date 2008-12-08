#import <UIKit/UIKit.h>

@interface SelectionController : UITableViewController {
	NSString *title;
	id dataSource;
	NSString *keyPath;
	NSArray *collection;
	NSInteger selected;
}
@property (assign) id dataSource;
@property (assign) NSString *keyPath;
@property (retain) NSArray *collection;

- (id)initWithTitle:(NSString*)title;

@end
