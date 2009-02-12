#import <UIKit/UIKit.h>


@interface CustomTableCell : UITableViewCell {
}

+(NSString*) cellId;
+(NSString*) nibName;

+(id) dequeOrCreateInTable: (UITableView*)tableView;


@end
