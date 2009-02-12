#import "CustomTableCell.h"
#import "NSString+Utils.h"


@implementation CustomTableCell

+(id) loadCell{
	NSArray* objects = [[NSBundle mainBundle] loadNibNamed:[self nibName] owner:self options:nil];
	if(objects.count == 0)
		[NSException raise:@"Wrong nib for custom cell" format:@"Can't find nib '%@' for custom cell '%@'", [self nibName], [self class]];
		
	id cell = [objects objectAtIndex:0];
	if([cell class] != [self class])
		[NSException raise:@"Wrong nib for custom cell" format:@"Nib for '%@' must contain one TableViewCell, "
		 "and its class must be '%@'", [self nibName], [self class]];
	
	if([[cell reuseIdentifier] isKindOfClass: [NSNull class]] || [[cell reuseIdentifier] isEmpty])
		[NSException raise:@"Wrong nib for custom cell" format:@"Identifier of custom cell in nib '%@' must not be empty", [self nibName]];		
	
	return cell;
}

+(NSString*) cellId{
	return [[self class] description];
}

+(NSString*) nibName{
	return [[self class] description];
}

+(id) dequeOrCreateInTable: (UITableView*)tableView{
    
    UITableViewCell*  cell = [tableView dequeueReusableCellWithIdentifier: [self cellId]];
    if (cell == nil)
		cell = [self loadCell];   
	
	return cell;
}



@end
