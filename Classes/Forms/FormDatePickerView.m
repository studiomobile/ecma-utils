#import "FormDatePickerView.h"

@implementation FormDatePickerView

@synthesize delegate;
@synthesize date;

- (void)setDate:(NSDate*)newDate {
    if(date != newDate) {
        [date release];
        date = [newDate retain];
    }
}


- (UIBarButtonItem*)toolbarSpace {
    return [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace 
                                                          target:nil 
                                                          action:nil] autorelease];
}


- (void)updateLabel {
    labelItem.title = self.date ? [labelDateFormatter stringFromDate:self.date] : @"";
}


- (void)reconfigureWithDescriptor:(FormFieldDescriptor*)desc {
    NSNumber *modeNumber = [desc.options objectForKey:@"datePicker.datePickerMode"];
    datePicker.datePickerMode = modeNumber ? [modeNumber integerValue] : UIDatePickerModeDateAndTime;

    NSNumber *minuteIntervalNumber = [desc.options objectForKey:@"datePicker.minuteInterval"];
    datePicker.minuteInterval = minuteIntervalNumber ? [minuteIntervalNumber integerValue] : 1;

    datePicker.maximumDate = [desc.options objectForKey:@"datePicker.maximumDate"];
    datePicker.minimumDate = [desc.options objectForKey:@"datePicker.minimumDate"];
	
	NSNumber *buttonsStyleNumber = [desc.options objectForKey:@"datePicker.buttonsStyle"];
    UIBarButtonItemStyle buttonsStyle = buttonsStyleNumber ? [buttonsStyleNumber integerValue] : UIBarButtonItemStyleBordered;

    NSDate *descDate = desc.value;
    [self setDate:(descDate ? descDate : [NSDate date])];
    [datePicker setDate:date animated:NO];
    
    if(![date isEqual:descDate]) {
        [delegate formDatePickerViewDateChanged:self];
    }
    
    NSMutableArray *items = [NSMutableArray array];

    NSNumber *allowsClearNumber = [desc.options objectForKey:@"allowsClear"];
    if([allowsClearNumber boolValue]) {
        UIBarButtonItem *clearButton = [[[UIBarButtonItem alloc] initWithTitle:@"Clear" 
                                                                         style:buttonsStyle 
                                                                        target:self 
                                                                        action:@selector(datePickerClear)] autorelease];
        
        [items addObject:clearButton];

        [items addObject:[self toolbarSpace]];
    }
    
    [labelDateFormatter release];
    labelDateFormatter = [NSDateFormatter new];
    [labelDateFormatter setDateFormat:[desc.options objectForKey:@"labelDateFormat"]];
    
    labelItem = [[[UIBarButtonItem alloc] initWithTitle:@"" 
                                                  style:UIBarButtonItemStylePlain
                                                 target:nil 
                                                 action:nil] autorelease];
    [items addObject:labelItem];
    [self updateLabel];
    
    [items addObject:[self toolbarSpace]];
    
    UIBarButtonItem *doneButton = [[[UIBarButtonItem alloc] initWithTitle:@"Done" 
                                                                    style:buttonsStyle 
                                                                   target:self 
                                                                   action:@selector(datePickerDone)] autorelease];
    
    [items addObject:doneButton];
    
    [toolbar setItems:items];
}

- (void)changeDate:(NSDate*)d {
    [self setDate:d];
    [self updateLabel];
    [delegate formDatePickerViewDateChanged:self];
}


- (void)datePickerValueChanged {
    [self changeDate:datePicker.date];
}


- (void)datePickerDone {
    [delegate formDatePickerViewDone:self];
}


- (void)datePickerClear {
    [self changeDate:nil];
    [delegate formDatePickerViewDone:self];
}


- (id)initWithWidth:(CGFloat)width {
    if(self = [super initWithFrame:CGRectZero]) {
        
        toolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, width, 44)];
        toolbar.barStyle = UIBarStyleBlackOpaque;
        [self addSubview:toolbar];
        
        datePicker = [[UIDatePicker alloc] init];
        datePicker.frame = CGRectMake(0, toolbar.frame.size.height, datePicker.frame.size.width, datePicker.frame.size.height);
        [datePicker addTarget:self action:@selector(datePickerValueChanged) forControlEvents:UIControlEventValueChanged];
        
        [self addSubview:datePicker];
        
        CGFloat height = toolbar.frame.size.height + datePicker.frame.size.height;
        self.frame = CGRectMake(0, 0, width, height);
    }
    
    return self;
}


- (void)dealloc {
    [datePicker release];
    [toolbar release];
    [labelDateFormatter release];
    
    [super dealloc];
}

@end
