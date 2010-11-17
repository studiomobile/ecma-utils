#pragma GCC diagnostic ignored "-Wdeprecated-declarations"

#import "SelectionController.h"

@implementation SelectionController

@synthesize title;
@synthesize dataSource;
@synthesize keyPath;
@synthesize collection;
@synthesize singleClickSelection;

- (id)initWithDelegate:(id<SelectionControllerDelegate>)aDelegate title:(NSString*)aTitle {
	if (![super init]) return nil;
	delegate = aDelegate;
    title = [aTitle retain];
    singleClickSelection = YES;
	return self;
}


// for backward compatibility
- (id)initWithTitle:(NSString*)aTitle {
	return [self initWithDelegate:nil title:aTitle];
}


- (void)loadView {
	tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
	tableView.delegate = self;
	tableView.dataSource = self;
	self.view = tableView;
}


- (void)viewDidLoad {
	self.navigationItem.title = title;
	selected = [collection indexOfObject:[dataSource valueForKeyPath:keyPath]];
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return collection.count;
}


- (UITableViewCell *)tableView:(UITableView *)tView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	static NSString *cellId = @"SelectionCellIdentifier";
	UITableViewCell *cell = [tView dequeueReusableCellWithIdentifier:cellId];
	if (cell == nil) {
		cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                       reuseIdentifier:cellId] autorelease];
	}
	
	cell.text = [[collection objectAtIndex:indexPath.row] description];
	cell.accessoryType = indexPath.row == selected ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;

	return cell;
}


- (void)tableView:(UITableView *)tView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    selected = indexPath.row;
	id selectedObject = [collection objectAtIndex:selected];
	[dataSource setValue:selectedObject forKeyPath:keyPath];
    if (singleClickSelection) {
		if (delegate) {
            [delegate selectionControllerWishToPop:self];  
        } else {
            [self.navigationController popViewControllerAnimated:YES];
        }	
    } else {
        [tView reloadData];
    }
}


- (void)dealloc {
	[title release];
	[keyPath release];
	[collection release];
    
    [tableView release];
    
	[super dealloc];
}

@end

