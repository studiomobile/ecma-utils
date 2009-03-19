#import <Foundation/Foundation.h>


@interface CustomTableCell : UITableViewCell {
}

+(NSString*) cellId;
+(NSString*) nibName;

+(id) dequeOrCreateInTable: (UITableView*)tableView;


@end
