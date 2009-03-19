#import "CustomTableCell.h"
#import "NSString+Utils.h"


@implementation CustomTableCell

+(id)findCellIn: (NSArray*)objects{
	for(id obj in objects){
 		if([obj isKindOfClass: self]){
			return obj;
		}
	}
		   
	return nil;
}

+(id) loadCell{
	NSArray* objects = [[NSBundle mainBundle] loadNibNamed:[self nibName] owner:self options:nil];
	
	if(!objects){
		[NSException raise:@"NibNotFound" format:@"Can't find nib named '%@' for custom cell '%@'", [self nibName], [self class]];
	}
		
	id cell = [self findCellIn: objects];
	if(!cell){
		[NSException raise:@"WrongNibFormat" format:@"Nib for '%@' must contain one TableViewCell, "
		 "and its class must be '%@'", [self nibName], [self class]];	
	}

	[cell setValue:[self cellId] forKey:@"_reuseIdentifier"];	
	
	return cell;
}

+(NSString*) cellId{
	return [self description];
}

+(NSString*) nibName{
	return [self description];
}

+(id) dequeOrCreateInTable: (UITableView*)tableView{
    
    UITableViewCell*  cell = [tableView dequeueReusableCellWithIdentifier: [self cellId]];
    if (cell == nil){
		cell = [self loadCell];   		
	}
	
	return cell;
}



@end
