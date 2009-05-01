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

- (void)reconfigureWithDescriptor:(FormFieldDescriptor*)desc {
    NSNumber *modeNumber = [desc.options objectForKey:@"datePicker.datePickerMode"];
    datePicker.datePickerMode = modeNumber ? [modeNumber integerValue] : UIDatePickerModeDateAndTime;

    NSNumber *minuteIntervalNumber = [desc.options objectForKey:@"datePicker.minuteInterval"];
    datePicker.minuteInterval = minuteIntervalNumber ? [minuteIntervalNumber integerValue] : 1;

    NSNumber *buttonsStyleNumber = [desc.options objectForKey:@"datePicker.buttonsStyle"];
    UIBarButtonItemStyle buttonsStyle = buttonsStyleNumber ? [buttonsStyleNumber integerValue] : UIBarButtonItemStyleBordered;

    NSDate *descDate = desc.value;
    [self setDate:(descDate ? descDate : [NSDate date])];
    [datePicker setDate:date animated:NO];
    
    if(![date isEqual:descDate]) {
        [delegate formDatePickerViewDateChanged:self];
    }
    
    NSMutableArray *items = [NSMutableArray array];

    if([desc.options objectForKey:@"allowsClear"]) {
        UIBarButtonItem *clearButton = [[[UIBarButtonItem alloc] initWithTitle:@"Clear" 
                                                                         style:buttonsStyle 
                                                                        target:self 
                                                                        action:@selector(datePickerClear)] autorelease];
        
        [items addObject:clearButton];
    }
    
    UIBarButtonItem *space = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace 
                                                                            target:nil 
                                                                            action:nil] autorelease];
    
    [items addObject:space];
    
    UIBarButtonItem *doneButton = [[[UIBarButtonItem alloc] initWithTitle:@"Done" 
                                                                    style:buttonsStyle 
                                                                   target:self 
                                                                   action:@selector(datePickerDone)] autorelease];
    
    [items addObject:doneButton];
    
    [toolbar setItems:items];
}

- (void)changeDate:(NSDate*)d {
    [self setDate:d];
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
    
    [super dealloc];
}

@end
