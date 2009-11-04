#import "SegmentedControlCell.h"

@implementation SegmentedControlCell

- (void)layoutControls:(CGRect)rect {
    CGRect old = segmentedControl.frame;
    segmentedControl.frame = CGRectMake(rect.origin.x, rect.origin.y + (rect.size.height - old.size.height)/2.0, old.size.width, old.size.height);
}


- (NSArray*)getItems {
    return [self.fieldDescriptor getCollection];
}

- (void)onFieldDescriptorUpdate {
    [super onFieldDescriptorUpdate];

    [items release];
    items = [self getItems];

    [segmentedControl removeFromSuperview];
    [segmentedControl release];
    
    segmentedControl = [[UISegmentedControl alloc] initWithItems:items];
    segmentedControl.segmentedControlStyle = UISegmentedControlStyleBar;
    segmentedControl.tintColor = [UIColor lightGrayColor];
    [segmentedControl addTarget:self action:@selector(switched) forControlEvents:UIControlEventValueChanged];
    [self.contentView addSubview:segmentedControl];
    
	segmentedControl.selectedSegmentIndex = [items indexOfObject:self.fieldDescriptor.value];
}


- (void)switched {
    self.fieldDescriptor.value = [items objectAtIndex:segmentedControl.selectedSegmentIndex];
}


- (void)dealloc {
    [segmentedControl release];
    [items release];
    
    [super dealloc];
}


@end
