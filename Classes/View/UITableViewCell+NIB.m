#import "UITableViewCell+NIB.h"

@implementation UITableViewCell (NIB)

+ (id)loadCellOfType: (Class)tp fromNib: (NSString*)nibName withId: (NSString*)reuseId {
	NSArray* objects = [[NSBundle mainBundle] loadNibNamed:nibName owner:self options:nil];
	
	for (id object in objects) {
		if ([object isKindOfClass:tp]) {
			UITableViewCell *cell = object;
			[cell setValue:reuseId forKey:@"_reuseIdentifier"];	
			return cell;
		}
	}

	[NSException raise:@"WrongNibFormat" format:@"Nib for '%@' must contain one TableViewCell, and its class must be '%@'", nibName, tp];	
	
	return nil;
}


+ (NSString*)cellID { return [self description]; }


+ (NSString*)nibName { return [self description]; }


+ (id)dequeOrCreateInTable:(UITableView*)tableView 
                    ofType:(Class)tp 
                   fromNib:(NSString*)nibName 
                    withId:(NSString*)reuseId {
    
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:reuseId];
	return cell ? cell : [self loadCellOfType:tp fromNib:nibName withId:reuseId];
}


+ (id)dequeOrCreateInTable:(UITableView*)tableView {
	return [self dequeOrCreateInTable:tableView withId:[self cellID]];
}


+ (id)dequeOrCreateInTable:(UITableView*)tableView withId:(NSString*)cellId {
	return [self dequeOrCreateInTable:tableView 
                               ofType:self 
                              fromNib:[self nibName] 
                               withId:cellId];
}


+ (id)loadFromNib{
	return [self loadCellOfType:self fromNib:[self nibName] withId:[self cellID]];
}

@end
