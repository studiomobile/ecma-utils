#import <UIKit/UIKit.h>

@class PagerController;

@protocol PagerControllerDataSource
- (NSUInteger)numberOfPagesInPager:(PagerController*)pager;
- (UIView*)viewForPage:(NSUInteger)pageIndex inPager:(PagerController*)pager;
@end

@protocol PagerControllerDelegate
- (void)pagerController:(PagerController*)pager didSwitchToPage:(NSUInteger)page;
@end



@interface PagerController : UIViewController<UIScrollViewDelegate> {
    IBOutlet UIScrollView *scroll;
    IBOutlet UIPageControl *pager;
    IBOutlet id buttonLeft;
    IBOutlet id buttonRight;
    id<PagerControllerDelegate> delegate;
    id<PagerControllerDataSource> dataSource;
    NSMutableArray *pages;
    NSUInteger loadMargin;
    NSUInteger minLoadedPage;
    NSUInteger maxLoadedPage;
    BOOL animating;
}
@property (nonatomic, assign) id<PagerControllerDelegate> delegate;
@property (nonatomic, assign) id<PagerControllerDataSource> dataSource;
@property (nonatomic, readonly) NSUInteger currentPage;
@property (nonatomic, assign) NSUInteger loadMargin;
@property (nonatomic, assign) BOOL pagingEnabled;

- (void)switchPage:(NSUInteger)page animated:(BOOL)animated;

- (IBAction)reloadData;

- (IBAction)scrollRight;
- (IBAction)scrollLeft;

@end
