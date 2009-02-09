#import "SelectionController.h"

@implementation SelectionController

@synthesize title;
@synthesize dataSource;
@synthesize keyPath;
@synthesize collection;


- (id)initWithTitle:(NSString*)aTitle {
	if (self = [super initWithStyle:UITableViewStyleGrouped]) {
		title = [aTitle retain];
	}
	return self;
}


- (void)loadView {
	UITableView *table = [[[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped] autorelease];
	table.delegate = self;
	table.dataSource = self;
	self.view = table;
}


- (void)viewDidLoad {
	self.navigationItem.title = title;
	selected = [collection indexOfObject:[dataSource valueForKeyPath:keyPath]];
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return collection.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	
	static NSString *cellId = @"SelectionCellIdentifier";
	
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
	if (cell == nil) {
		cell = [[[UITableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:cellId] autorelease];
	}
	
	cell.text = [[collection objectAtIndex:indexPath.row] description];
	cell.accessoryType = indexPath.row == selected ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;

	return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	id selectedObject = [collection objectAtIndex:indexPath.row];
	[dataSource setValue:selectedObject forKeyPath:keyPath];
	[self.navigationController popViewControllerAnimated:YES];
}


- (void)dealloc {
	[title release];
	[keyPath release];
	[collection release];
	[super dealloc];
}


@end

