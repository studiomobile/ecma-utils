#pragma GCC diagnostic ignored "-Wdeprecated-declarations"

#import "SelectionController.h"

@implementation SelectionController

@synthesize title;
@synthesize dataSource;
@synthesize keyPath;
@synthesize collection;
@synthesize singleClickSelection;

- (id)initWithTitle:(NSString*)aTitle {
	if (![super init]) return nil;
    title = [aTitle retain];
    singleClickSelection = YES;
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
    cell.selectionStyle = UITableViewCellSelectionStyleNone;

	return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    selected = indexPath.row;
	id selectedObject = [collection objectAtIndex:selected];
	[dataSource setValue:selectedObject forKeyPath:keyPath];
    if (singleClickSelection) {
        [self.navigationController popViewControllerAnimated:YES];
    } else {
        [tableView reloadData];
    }
}


- (void)dealloc {
	[title release];
	[keyPath release];
	[collection release];
	[super dealloc];
}

@end

