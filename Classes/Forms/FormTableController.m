#import "FormTableController.h"

#import "TextEditController.h"
#import "SelectionController.h"

@implementation FormTableController

- (void)viewDidLoad {
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_updateData) name:UIKeyboardDidHideNotification object:nil];
	[super viewDidLoad];
}

- (void)dealloc {
	[[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardDidHideNotification object:nil];
	[super dealloc];
}

- (FormFieldDescriptor*)stringFieldWithTitle:(NSString*)title forProperty:(NSString*)keyPath ofObject:(id)object {
	FormFieldDescriptor *desc = [FormFieldDescriptor new];
	desc.title = title;
	desc.dataSource = object;
	desc.keyPath = keyPath;
	desc.editableInplace = YES;
	return [desc autorelease];
}

- (FormFieldDescriptor*)secureFieldWithTitle:(NSString*)title forProperty:(NSString*)keyPath ofObject:(id)object {
	FormFieldDescriptor *desc = [self stringFieldWithTitle:title forProperty:keyPath ofObject:object];
	desc.secure = YES;
	return desc;
}

- (FormFieldDescriptor*)textFieldWithTitle:(NSString*)title forProperty:(NSString*)keyPath ofObject:(id)object {
	FormFieldDescriptor *desc = [self stringFieldWithTitle:title forProperty:keyPath ofObject:object];
	desc.editableInplace = NO;
	return desc;
}

- (FormFieldDescriptor*)collectionFieldWithTitle:(NSString*)title forProperty:(NSString*)keyPath ofObject:(id)object {
	FormFieldDescriptor *desc = [self textFieldWithTitle:title forProperty:keyPath ofObject:object];
	desc.selectable = YES;
	return desc;
}

- (FormFieldDescriptor*)customFieldWithTitle:(NSString*)title forProperty:(NSString*)keyPath ofObject:(id)object {
	FormFieldDescriptor *desc = [FormFieldDescriptor new];

	desc.custom = YES;
	desc.title = title;
	desc.dataSource = object;
	desc.keyPath = keyPath;
	desc.editableInplace = NO;
	
	return [desc autorelease];
}

- (void)enableButton:(BOOL)enable {
}

- (NSInteger)numberOfDataSections {
	return 0;
}

- (NSInteger)numberOfFieldsInDataSection:(NSInteger)section {
	return 0;
}

- (FormFieldDescriptor*)descriptorForField:(NSIndexPath*)indexPath {
	return nil;
}

- (NSString*)missingFieldsDescriptionForSection:(NSInteger)section {
	return nil;
}

- (BOOL)valid {
	for(int i = 0; i < [self numberOfDataSections]; i++) {
		if([[self missingFieldsDescriptionForSection:i] length] != 0) return NO;
	}
	
	return YES;
}

- (NSString*)buttonTitle {
	return nil;
}

- (IBAction)buttonPressed {
}

- (NSArray*)collectionForField:(NSIndexPath*)indexPath {
	return nil;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	NSInteger sections = [self numberOfDataSections];
	
	if ([self buttonTitle].length > 0 && [self valid]) { sections++; }
    return sections;
}

- (void)_updateData {
	[self enableButton:[self valid]];
	[self.table reloadData];
}

- (void)reloadForm {
    [self _updateData];
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
	return section < [self numberOfDataSections] ? [self missingFieldsDescriptionForSection:section] : nil;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return section < [self numberOfDataSections] ? [self numberOfFieldsInDataSection:section] : 1;
}

- (StaticFormCell*)immutableCellWithDescriptor:(FormFieldDescriptor*)desc{
	static NSString *cellId = @"ImmutableFieldCell";
	StaticFormCell *cell = (StaticFormCell*)[self.table dequeueReusableCellWithIdentifier:cellId];
	if (cell == nil) { 
        cell = [[[StaticFormCell alloc] initWithFrame:CGRectZero reuseIdentifier:cellId] autorelease]; 
        cell.title.textColor = [UIColor grayColor];
        cell.value.textColor = [UIColor grayColor];
    }
	
	cell.fieldDescriptor = desc;
    
	return cell;
}

- (StaticFormCell*)staticCellWithDescriptor:(FormFieldDescriptor*)desc {
	static NSString *cellId = @"StaticFieldCell";
	StaticFormCell *cell = (StaticFormCell*)[self.table dequeueReusableCellWithIdentifier:cellId];
	if (cell == nil) { cell = [[[StaticFormCell alloc] initWithFrame:CGRectZero reuseIdentifier:cellId] autorelease]; }
	
	cell.fieldDescriptor = desc;

	return cell;
}

- (StaticFormCell*)textCellWithDescriptor:(FormFieldDescriptor*)desc {
	static NSString *cellId = @"TextCell";
	StaticFormCell *cell = (StaticFormCell*)[self.table dequeueReusableCellWithIdentifier:cellId];
	if (cell == nil) { 
        cell = [[[StaticFormCell alloc] initWithFrame:CGRectZero reuseIdentifier:cellId] autorelease]; 
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
	cell.fieldDescriptor = desc;
	return cell;
}

- (UITableViewCell*)customCellWithDescriptor:(FormFieldDescriptor*)desc forIndexPath:indexPath {
	return [self staticCellWithDescriptor:desc];
}

- (TextFieldCell*)settingsCellWithDescriptor:(FormFieldDescriptor*)desc {
	static NSString *cellId = @"SettingsCell";
	TextFieldCell *cell = (TextFieldCell*)[self.table dequeueReusableCellWithIdentifier:cellId];
	if (cell == nil) { cell = [[[TextFieldCell alloc] initWithFrame:CGRectZero reuseIdentifier:cellId] autorelease]; }
	
	cell.fieldDescriptor = desc;
    cell.value.delegate = self;
	return cell;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	if (indexPath.section == [self numberOfDataSections]) {
		static NSString *CellIdentifier = @"ButtonCell";
		UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
		if (cell == nil) {
			cell = [[[UITableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:CellIdentifier] autorelease];
			cell.textAlignment = UITextAlignmentCenter;
			cell.selectionStyle = UITableViewCellSelectionStyleGray;
		}
		cell.text = [self buttonTitle];
		return cell;
	}
	
	FormFieldDescriptor *desc = [self descriptorForField:indexPath];
	if(desc.custom) {
		return [self customCellWithDescriptor:desc forIndexPath:indexPath];
	} else if (desc.editableInplace) {
		return [self settingsCellWithDescriptor:desc];
	} else {
		return [self textCellWithDescriptor:desc];
	}
}

- (void)didSelectCustomCellAtIndexPath:(NSIndexPath*)indexPath {
}

- (NSString*)selectControllerTitleForDescriptor:(FormFieldDescriptor*)desc indexPath:(NSIndexPath*)indexPath {
	return [NSString stringWithFormat:@"Select %@", [desc.title lowercaseString]];
}

- (NSString*)textEditControllerTitleForDescriptor:(FormFieldDescriptor*)desc indexPath:(NSIndexPath*)indexPath {
	return [NSString stringWithFormat:@"Edit %@", [desc.title lowercaseString]];
}

- (UIViewController*)selectionControllerForIndexPath:(NSIndexPath*)indexPath title:(NSString*)title descriptor:(FormFieldDescriptor*)desc {
    SelectionController *selection = [[[SelectionController alloc] initWithTitle:title] autorelease];
    selection.dataSource = desc.dataSource;
    selection.keyPath = desc.keyPath;
    selection.collection = [self collectionForField:indexPath];
    return selection;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self scrollToField:indexPath animated:YES];
    
	if (indexPath.section == [self numberOfDataSections]) {
		[self buttonPressed];
		return;
	}
	
	FormFieldDescriptor *desc = [self descriptorForField:indexPath];

	if(desc.custom) {
		[self didSelectCustomCellAtIndexPath:indexPath];
		return;
	}
	
	if (desc.editableInplace) {
		return;
	}
	
	if (desc.selectable) {
		NSString *title = [self selectControllerTitleForDescriptor:desc indexPath:indexPath];
		UIViewController *selection = [self selectionControllerForIndexPath:indexPath title:title descriptor:(FormFieldDescriptor*)desc];
		[self.navigationController pushViewController:selection animated:YES];
	} else {
		NSString *title = [self textEditControllerTitleForDescriptor:desc indexPath:indexPath];
		TextEditController *textEdit = [[[TextEditController alloc] initWithTitle:title] autorelease];
		textEdit.dataSource = desc.dataSource;
		textEdit.keyPath = desc.keyPath;
		[self.navigationController pushViewController:textEdit animated:YES];
	}
}

- (void)viewWillAppear:(BOOL)animated {
	[self _updateData];
	[super viewWillAppear:animated];
}


@end

