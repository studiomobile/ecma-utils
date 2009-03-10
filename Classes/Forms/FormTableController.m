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

- (FormFieldDescriptor*)fieldWithTitle:(NSString*)title forProperty:(NSString*)keyPath ofObject:(id)object type:(FormFieldDescriptorType)type {
	FormFieldDescriptor *desc = [FormFieldDescriptor new];
	desc.title = title;
	desc.dataSource = object;
	desc.keyPath = keyPath;
    desc.type = type;
	return [desc autorelease];
}

- (FormFieldDescriptor*)stringFieldWithTitle:(NSString*)title forProperty:(NSString*)keyPath ofObject:(id)object {
	FormFieldDescriptor *desc = [self fieldWithTitle:title forProperty:keyPath ofObject:object type:FORM_FIELD_DESCRIPTOR_TEXT_FIELD];
	return desc;
}

- (FormFieldDescriptor*)secureFieldWithTitle:(NSString*)title forProperty:(NSString*)keyPath ofObject:(id)object {
	FormFieldDescriptor *desc = [self stringFieldWithTitle:title forProperty:keyPath ofObject:object];
    [desc.options setValue:[NSNumber numberWithBool:YES] forKey:@"value.secureTextEntry"];
	return desc;
}

- (FormFieldDescriptor*)textFieldWithTitle:(NSString*)title forProperty:(NSString*)keyPath ofObject:(id)object {
	return [self fieldWithTitle:title forProperty:keyPath ofObject:object type:FORM_FIELD_DESCRIPTOR_TEXT_AREA];
}

- (FormFieldDescriptor*)collectionFieldWithTitle:(NSString*)title forProperty:(NSString*)keyPath ofObject:(id)object {
	return [self fieldWithTitle:title forProperty:keyPath ofObject:object type:FORM_FIELD_DESCRIPTOR_COLLECTION];
}

- (FormFieldDescriptor*)customFieldWithTitle:(NSString*)title forProperty:(NSString*)keyPath ofObject:(id)object {
	return [self fieldWithTitle:title forProperty:keyPath ofObject:object type:FORM_FIELD_DESCRIPTOR_CUSTOM];
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

- (StaticFormCell*)disclosingCellWithDescriptor:(FormFieldDescriptor*)desc {
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

- (TextFieldCell*)textFieldCellWithDescriptor:(FormFieldDescriptor*)desc {
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
    
    switch (desc.type) {
        case FORM_FIELD_DESCRIPTOR_TEXT_FIELD:
            return [self textFieldCellWithDescriptor:desc];
            break;
        case FORM_FIELD_DESCRIPTOR_TEXT_AREA:
        case FORM_FIELD_DESCRIPTOR_COLLECTION:
            return [self disclosingCellWithDescriptor:desc];
            break;
        default:
            break;
    }
    
    return [self customCellWithDescriptor:desc forIndexPath:indexPath];
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
	if (indexPath.section == [self numberOfDataSections]) {
		[self buttonPressed];
		return;
	}
	
    [self scrollToField:indexPath animated:YES];

	FormFieldDescriptor *desc = [self descriptorForField:indexPath];

	if(desc.type == FORM_FIELD_DESCRIPTOR_CUSTOM) {
		[self didSelectCustomCellAtIndexPath:indexPath];
	} else if (desc.type == FORM_FIELD_DESCRIPTOR_COLLECTION) {
		NSString *title = [self selectControllerTitleForDescriptor:desc indexPath:indexPath];
		UIViewController *selection = [self selectionControllerForIndexPath:indexPath title:title descriptor:(FormFieldDescriptor*)desc];
		[self.navigationController pushViewController:selection animated:YES];
	} else if(desc.type == FORM_FIELD_DESCRIPTOR_TEXT_AREA) {
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

