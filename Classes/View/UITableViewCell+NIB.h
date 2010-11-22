#import <UIKit/UIKit.h>

@interface UITableViewCell (NIB)

+ (NSString*)cellID;
+ (NSString*)nibName;

+ (id)dequeOrCreateInTable:(UITableView*)tableView;
+ (id)dequeOrCreateInTable:(UITableView*)tableView withId:(NSString*)cellId;
+ (id)dequeOrCreateInTable:(UITableView*)tableView ofType: (Class)tp fromNib: (NSString*)nibName withId: (NSString*)reuseId;

+ (id)loadCellOfType: (Class)tp fromNib: (NSString*)nibName withId: (NSString*)reuseId;
+ (id)loadFromNib;

@end
