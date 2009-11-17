#import "TitledFormCell.h"

@interface SegmentedControlCell : TitledFormCell {
    UISegmentedControl *segmentedControl;
    NSArray *items;
    
    BOOL alignRight;
}

@end
