#import "UITableViewCell+NIB.h"

@implementation UITableViewCell (NIB)

+ (id)loadCell {
	NSArray* objects = [[NSBundle mainBundle] loadNibNamed:[self nibName] owner:self options:nil];
	
	for (id object in objects) {
		if ([object isKindOfClass:self]) {
			UITableViewCell *cell = object;
			[cell setValue:[self cellID] forKey:@"_reuseIdentifier"];	
			return cell;
		}
	}

	[NSException raise:@"WrongNibFormat" format:@"Nib for '%@' must contain one TableViewCell, and its class must be '%@'", [self nibName], [self class]];	
	
	return nil;
}


+ (NSString*)cellID { return [self description]; }


+ (NSString*)nibName { return [self description]; }


+ (id)dequeOrCreateInTable:(UITableView*)tableView {
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:[self cellID]];
	return cell ? cell : [self loadCell];
}

@end
