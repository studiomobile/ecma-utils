#import "FormTableController.h"

#import "TextEditController.h"
#import "SelectionController.h"
#import "AgreementController.h"

#import <objc/runtime.h>

@implementation FormTableController

@synthesize currentIndexPath;

- (void)viewDidLoad {
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadForm) name:UIKeyboardDidHideNotification object:nil];
	[super viewDidLoad];
}


- (void)dealloc {
    [datePickerView removeFromSuperview];
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


- (FormFieldDescriptor*)textFieldWithTitle:(NSString*)title forProperty:(NSString*)keyPath ofObject:(id)object {
	return [self fieldWithTitle:title forProperty:keyPath ofObject:object type:FORM_FIELD_DESCRIPTOR_TEXT_FIELD];
}


- (FormFieldDescriptor*)emailFieldWithTitle:(NSString*)title forProperty:(NSString*)keyPath ofObject:(id)object {
    FormFieldDescriptor *desc = [self textFieldWithTitle:title forProperty:keyPath ofObject:object];
    [desc.options setObject:[NSNumber numberWithInteger:UIKeyboardTypeEmailAddress] forKey:@"value.keyboardType"];
    return desc;
}


- (FormFieldDescriptor*)secureFieldWithTitle:(NSString*)title forProperty:(NSString*)keyPath ofObject:(id)object {
	FormFieldDescriptor *desc = [self textFieldWithTitle:title forProperty:keyPath ofObject:object];
    [desc.options setValue:[NSNumber numberWithBool:YES] forKey:@"value.secureTextEntry"];
	return desc;
}


- (FormFieldDescriptor*)textEditFieldWithTitle:(NSString*)title forProperty:(NSString*)keyPath ofObject:(id)object {
	return [self fieldWithTitle:title forProperty:keyPath ofObject:object type:FORM_FIELD_DESCRIPTOR_TEXT_AREA];
}


- (FormFieldDescriptor*)collectionFieldWithTitle:(NSString*)title forProperty:(NSString*)keyPath ofObject:(id)object {
	return [self fieldWithTitle:title forProperty:keyPath ofObject:object type:FORM_FIELD_DESCRIPTOR_COLLECTION];
}


- (FormFieldDescriptor*)switchFieldWithTitle:(NSString*)title forProperty:(NSString*)keyPath ofObject:(id)object {
	return [self fieldWithTitle:title forProperty:keyPath ofObject:object type:FORM_FIELD_DESCRIPTOR_SWITCH];
}


- (FormFieldDescriptor*)agreementFieldWithTitle:(NSString*)title forProperty:(NSString*)keyPath ofObject:(id)object {
	return [self fieldWithTitle:title forProperty:keyPath ofObject:object type:FORM_FIELD_DESCRIPTOR_AGREEMENT];
}


- (FormFieldDescriptor*)dateTimeFieldWithTitle:(NSString*)title forProperty:(NSString*)keyPath ofObject:(id)object {
    return [self fieldWithTitle:title forProperty:keyPath ofObject:object type:FORM_FIELD_DESCRIPTOR_DATETIME];
}


- (FormFieldDescriptor*)dateFieldWithTitle:(NSString*)title forProperty:(NSString*)keyPath ofObject:(id)object {
    FormFieldDescriptor *desc = [self dateTimeFieldWithTitle:title forProperty:keyPath ofObject:object];
    [desc.options setObject:@"yyyy-MM-dd" forKey:@"formatter.dateFormat"];
    [desc.options setObject:[NSNumber numberWithInteger:UIDatePickerModeDate] forKey:@"datePicker.datePickerMode"];
    return desc;
}


- (FormFieldDescriptor*)timeFieldWithTitle:(NSString*)title forProperty:(NSString*)keyPath ofObject:(id)object {
    FormFieldDescriptor *desc = [self dateTimeFieldWithTitle:title forProperty:keyPath ofObject:object];
    [desc.options setObject:@"hh:mm a" forKey:@"formatter.dateFormat"];
    [desc.options setObject:[NSNumber numberWithInteger:UIDatePickerModeTime] forKey:@"datePicker.datePickerMode"];
    return desc;
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


- (NSInteger)numberOfButtons {
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


- (NSString*)buttonTitle:(NSInteger)buttonNumber {
	return nil;
}


- (IBAction)buttonPressed:(NSInteger)buttonNumber {
}


- (NSArray*)collectionForDescriptor:(FormFieldDescriptor*)desc atIndexPath:(NSIndexPath*)indexPath {
	return nil;
}


- (id)agreementDataForDescriptor:(FormFieldDescriptor*)desc atIndexPath:(NSIndexPath*)indexPath {
	return nil;
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return [self numberOfDataSections] + [self numberOfButtons];
}


- (void)reloadForm {
	[self enableButton:[self valid]];
	[self.table reloadData];
}


- (void)hideControls {
    [self hideDatePicker];
    [self hideKeyboard];
}


- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
	return section < [self numberOfDataSections] ? [self missingFieldsDescriptionForSection:section] : nil;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return section < [self numberOfDataSections] ? [self numberOfFieldsInDataSection:section] : 1;
}


- (FormCell*)formCellWithClass:(Class)klass reuseIdentifier:(NSString*)reuseIdentifier descriptor:(FormFieldDescriptor*)desc {
	FormCell *result = (FormCell*)[self.table dequeueReusableCellWithIdentifier:reuseIdentifier];
    if(!result) {
        result = [[[klass alloc] initWithFrame:CGRectZero reuseIdentifier:reuseIdentifier] autorelease];
    }
    
    result.fieldDescriptor = desc;
    return result;
}


- (StaticFormCell*)immutableCellWithDescriptor:(FormFieldDescriptor*)desc{
	StaticFormCell *cell = (StaticFormCell*)[self formCellWithClass:[StaticFormCell class] reuseIdentifier:@"ImmutableFieldCell" descriptor:desc]; 
    cell.title.textColor = [UIColor grayColor];
    cell.value.textColor = [UIColor grayColor];
	return cell;
}


- (StaticFormCell*)staticCellWithDescriptor:(FormFieldDescriptor*)desc {
	StaticFormCell *cell = (StaticFormCell*)[self formCellWithClass:[StaticFormCell class] reuseIdentifier:@"StaticFieldCell" descriptor:desc];
	return cell;
}


- (StaticFormCell*)disclosingCellWithDescriptor:(FormFieldDescriptor*)desc {
	StaticFormCell *cell = (StaticFormCell*)[self formCellWithClass:[StaticFormCell class] reuseIdentifier:@"DisclosingCell" descriptor:desc];; 
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	return cell;
}


- (TextFieldCell*)textFieldCellWithDescriptor:(FormFieldDescriptor*)desc {
	TextFieldCell *cell = (TextFieldCell*)[self formCellWithClass:[TextFieldCell class] reuseIdentifier:@"SettingsCell" descriptor:desc];
	return cell;
}


- (SwitchCell*)switchFieldCellWithDescriptor:(FormFieldDescriptor*)desc {
	SwitchCell *cell = (SwitchCell*)[self formCellWithClass:[SwitchCell class] reuseIdentifier:@"SwitchCell" descriptor:desc];
	return cell;
}


- (AgreementCell*)agreementFieldCellWithDescriptor:(FormFieldDescriptor*)desc {
	AgreementCell *cell = (AgreementCell*)[self formCellWithClass:[AgreementCell class] reuseIdentifier:@"AgreementCell" descriptor:desc];
	return cell;
}


- (DateTimeCell*)dateTimeFieldCellWithDescriptor:(FormFieldDescriptor*)desc {
	DateTimeCell *cell = (DateTimeCell*)[self formCellWithClass:[DateTimeCell class] reuseIdentifier:@"DateTimeCell" descriptor:desc];
	return cell;
}


- (UITableViewCell*)customCellWithDescriptor:(FormFieldDescriptor*)desc forIndexPath:indexPath {
	return [self staticCellWithDescriptor:desc];
}


- (NSInteger)buttonNumberByIndexPath:(NSIndexPath*)indexPath {
    return indexPath.section - [self numberOfDataSections];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	if (indexPath.section >= [self numberOfDataSections]) {
		static NSString *CellIdentifier = @"ButtonCell";
		UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
		if (cell == nil) {
			cell = [[[UITableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:CellIdentifier] autorelease];
			cell.textAlignment = UITextAlignmentCenter;
			cell.selectionStyle = UITableViewCellSelectionStyleGray;
		}
		cell.text = [self buttonTitle:[self buttonNumberByIndexPath:indexPath]];
		return cell;
	}
	
	FormFieldDescriptor *desc = [self descriptorForField:indexPath];
    
    switch (desc.type) {
        case FORM_FIELD_DESCRIPTOR_TEXT_FIELD:
            return [self textFieldCellWithDescriptor:desc];
            break;
        case FORM_FIELD_DESCRIPTOR_SWITCH:
            return [self switchFieldCellWithDescriptor:desc];
            break;
        case FORM_FIELD_DESCRIPTOR_AGREEMENT:
            return [self agreementFieldCellWithDescriptor:desc];
            break;
        case FORM_FIELD_DESCRIPTOR_DATETIME:
            return [self dateTimeFieldCellWithDescriptor:desc];
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


- (void)didSelectCustomCellForDescriptor:(FormFieldDescriptor*)desc atIndexPath:(NSIndexPath*)indexPath {
}


- (NSString*)selectControllerTitleForDescriptor:(FormFieldDescriptor*)desc indexPath:(NSIndexPath*)indexPath {
	return [NSString stringWithFormat:@"Select %@", [desc.title lowercaseString]];
}


- (NSString*)textEditControllerTitleForDescriptor:(FormFieldDescriptor*)desc indexPath:(NSIndexPath*)indexPath {
	return [NSString stringWithFormat:@"Edit %@", [desc.title lowercaseString]];
}


- (NSString*)agreementControllerTitleForDescriptor:(FormFieldDescriptor*)desc indexPath:(NSIndexPath*)indexPath {
	return [NSString stringWithFormat:@"%@", desc.title];
}


- (UIViewController*)selectionControllerForIndexPath:(NSIndexPath*)indexPath title:(NSString*)title descriptor:(FormFieldDescriptor*)desc collection:(NSArray*)collection {
    SelectionController *selection = [[[SelectionController alloc] initWithTitle:title] autorelease];
    selection.dataSource = desc.dataSource;
    selection.keyPath = desc.keyPath;
    selection.collection = collection;
    return selection;
}


- (UIViewController*)textEditControllerForIndexPath:(NSIndexPath*)indexPath title:(NSString*)title descriptor:(FormFieldDescriptor*)desc {
    TextEditController *textEdit = [[[TextEditController alloc] initWithTitle:title] autorelease];
    textEdit.dataSource = desc.dataSource;
    textEdit.keyPath = desc.keyPath;
    return textEdit;
}


- (UIViewController*)agreementControllerForIndexPath:(NSIndexPath*)indexPath title:(NSString*)title descriptor:(FormFieldDescriptor*)desc data:(id)data {
    AgreementController *agreementController = [[[AgreementController alloc] initWithTitle:title] autorelease];
    agreementController.dataSource = desc.dataSource;
    agreementController.keyPath = desc.keyPath;
    agreementController.html = (NSString*)data;
    return agreementController;
}


- (FormCell*)currentCell {
    return (FormCell*)[self.table cellForRowAtIndexPath:self.currentIndexPath];
}


- (FormDatePickerView*)datePickerView {
    if(!datePickerView) {
        datePickerView = [[[FormDatePickerView alloc] initWithWidth:self.view.bounds.size.width] autorelease];
        datePickerView.frame  = CGRectMake(0, self.view.bounds.size.height, datePickerView.frame.size.width, datePickerView.frame.size.height);
        datePickerView.delegate = self;
        [self.table.superview addSubview:datePickerView];
    }
    
    return datePickerView;
}


- (void)setDatePickerVisible:(BOOL)v {
    if(datePickerVisible == v) return;
    
    datePickerVisible = v;
    
    CGRect frame = self.datePickerView.frame;
    if(datePickerVisible) {
        frame.origin.y -= frame.size.height;
        [self adjustTableRelativeToFrame:frame frameView:self.view];
    } else {
        [self restoreTableFrame:NO];
        frame.origin.y += frame.size.height;
    }
    
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.3];
    
    self.datePickerView.frame = frame;
    
    [UIView commitAnimations];
}


- (void)showDatePickerForDescriptor:(FormFieldDescriptor*)desc {
    [self.datePickerView reconfigureWithDescriptor:desc];
    
    [self setDatePickerVisible:YES];
}


- (void)hideDatePicker {
    [self setDatePickerVisible:NO];
}


- (void)formDatePickerViewDone:(FormDatePickerView*)datePickerView {
    [self hideDatePicker];
}


- (void)formDatePickerViewDateChanged:(FormDatePickerView*)datePickerView {
    FormCell *cell = [self currentCell];
    [cell.fieldDescriptor.dataSource setValue:self.datePickerView.date forKey:cell.fieldDescriptor.keyPath];
    [cell onFieldDescriptorUpdate];
}


- (BOOL)pushControllersAnimated {
    return YES;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	if (indexPath.section >= [self numberOfDataSections]) {
		[self buttonPressed:[self buttonNumberByIndexPath:indexPath]];
		return;
	}
	
    self.currentIndexPath = indexPath;
	FormFieldDescriptor *desc = [self currentCell].fieldDescriptor;
    
    if(desc.type != FORM_FIELD_DESCRIPTOR_TEXT_FIELD) {
        [self hideKeyboard];
    }

    if(desc.type != FORM_FIELD_DESCRIPTOR_DATETIME) {
        [self hideDatePicker];
    }
    
	if(desc.type == FORM_FIELD_DESCRIPTOR_TEXT_FIELD) {
        TextFieldCell *cell = (TextFieldCell*)[self.table cellForRowAtIndexPath:indexPath];
        [cell edit];
	} else if(desc.type == FORM_FIELD_DESCRIPTOR_CUSTOM) {
		[self didSelectCustomCellForDescriptor:desc atIndexPath:indexPath];
	} else if (desc.type == FORM_FIELD_DESCRIPTOR_COLLECTION) {
		NSString *title = [self selectControllerTitleForDescriptor:desc indexPath:indexPath];
        NSArray *collection = [self collectionForDescriptor:desc atIndexPath:indexPath];
		UIViewController *selection = [self selectionControllerForIndexPath:indexPath title:title descriptor:(FormFieldDescriptor*)desc collection:collection];
		[self.navigationController pushViewController:selection animated:[self pushControllersAnimated]];
	} else if(desc.type == FORM_FIELD_DESCRIPTOR_TEXT_AREA) {
		NSString *title = [self textEditControllerTitleForDescriptor:desc indexPath:indexPath];
		UIViewController *textEdit = [self textEditControllerForIndexPath:indexPath title:title descriptor:desc];
		[self.navigationController pushViewController:textEdit animated:[self pushControllersAnimated]];
	} else if(desc.type == FORM_FIELD_DESCRIPTOR_AGREEMENT) {
		NSString *title = [self agreementControllerTitleForDescriptor:desc indexPath:indexPath];
        id data = [self agreementDataForDescriptor:desc atIndexPath:indexPath];
		UIViewController *agreementController = [self agreementControllerForIndexPath:indexPath title:title descriptor:(FormFieldDescriptor*)desc data:data];
		[self.navigationController pushViewController:agreementController animated:[self pushControllersAnimated]];
	} else if(desc.type == FORM_FIELD_DESCRIPTOR_DATETIME) {
        [self showDatePickerForDescriptor:desc];
	}
    
    if(desc.type != FORM_FIELD_DESCRIPTOR_TEXT_FIELD) {
        [self scrollToField:indexPath animated:YES];
    }
}


- (void)textFieldSelected {
    self.currentIndexPath = [self indexPathOfSelectedTextField];
    [self hideDatePicker];
}


- (void)viewWillAppear:(BOOL)animated {
	[self reloadForm];
	[super viewWillAppear:animated];
}

@end

