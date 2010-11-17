#import <UIKit/UIKit.h>

@class SelectionController;

@protocol SelectionControllerDelegate

- (void)selectionControllerWishToPop:(SelectionController*)ctrl;

@end


@interface SelectionController : UIViewController<UITableViewDataSource, UITableViewDelegate> {
	NSString *title;
	id dataSource;
	NSString *keyPath;
	NSArray *collection;
	NSInteger selected;
    BOOL singleClickSelection;
    
    UITableView *tableView;
	
	id<SelectionControllerDelegate> delegate;
}
@property (assign) id dataSource;
@property (assign) NSString *keyPath;
@property (retain) NSArray *collection;
@property (assign) BOOL singleClickSelection;

- (id)initWithDelegate:(id<SelectionControllerDelegate>)delegate title:(NSString*)title;
// for backward compatibility
- (id)initWithTitle:(NSString*)title;

@end
