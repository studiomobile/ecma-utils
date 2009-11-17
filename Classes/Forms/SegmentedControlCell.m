#import "SegmentedControlCell.h"

@implementation SegmentedControlCell

- (void)layoutControls:(CGRect)rect {
    rect = CGRectInset(rect, 0, 2);
    CGRect old = segmentedControl.frame;
    CGRect newRect = CGRectMake(rect.origin.x, rect.origin.y, old.size.width, rect.size.height);
    if (alignRight) {
        newRect = CGRectOffset(newRect, rect.size.width - newRect.size.width + 3, 0);
    }
    segmentedControl.frame = newRect;
}


- (NSArray*)getItems {
    return [self.fieldDescriptor getCollection];
}


- (void)onFieldDescriptorUpdate {
    [super onFieldDescriptorUpdate];

    NSNumber *alignRightNumber = [self.fieldDescriptor.options objectForKey:@"alignRight"];
    alignRight = alignRightNumber ? [alignRightNumber boolValue] : NO;

    [items release];
    items = [[self getItems] retain];

    [segmentedControl removeFromSuperview];
    [segmentedControl release];
    
    segmentedControl = [[UISegmentedControl alloc] initWithItems:items];
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
