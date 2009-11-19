#import "PagerController.h"

@implementation PagerController

@synthesize delegate;
@synthesize dataSource;
@synthesize loadMargin;


- (void)loadView {
    [super loadView];
    if (!self.view) {
        self.view = scroll;
    }
}


- (void)viewDidLoad {
    [super viewDidLoad];
    if (!scroll) {
        assert([self.view isKindOfClass:[UIScrollView class]]);
        scroll = (UIScrollView*)[self.view retain];
    }
    if (!pager) {
        pager = [UIPageControl new];
    }
    scroll.pagingEnabled = YES;
    if (loadMargin == 0) {
        loadMargin = 2;
    }
    scroll.delegate = self;
    pager.defersCurrentPageDisplay = YES;
    [pager addTarget:self action:@selector(switchPage) forControlEvents:UIControlEventValueChanged];
}


- (void)switchPage {
    [self switchPage:pager.currentPage animated:YES];
}


- (BOOL)pagingEnabled {
    return scroll.scrollEnabled;
}


- (void)setPagingEnabled:(BOOL)enabled {
    scroll.scrollEnabled = enabled;
}


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if (!pages.count) {
        [self reloadData];
    }
}


- (NSUInteger)currentPage {
    return pager.currentPage;
}


- (void)scrollRight {
    if (!animating) {
        [self switchPage:pager.currentPage+1 animated:YES];
    }
}


- (void)scrollLeft {
    if (!animating) {
        [self switchPage:pager.currentPage-1 animated:YES];
    }
}


- (void)reloadData {
    NSUInteger numberOfPages = [dataSource numberOfPagesInPager:self];
    CGSize pageSize = scroll.frame.size; 
    CGFloat totalWidth = numberOfPages * pageSize.width;
    pager.numberOfPages = numberOfPages;
    scroll.contentSize = CGSizeMake(totalWidth, pageSize.height);
    
    for (UIView *view in pages) {
        if ([view isKindOfClass:[UIView class]]) {
            [view removeFromSuperview];
        }
    }
    minLoadedPage = maxLoadedPage = 0;
    
    [pages autorelease];
    pages = [NSMutableArray new];
    for (int i = 0; i < numberOfPages; i++) {
        [pages addObject:[NSNull null]];
    }

    [self switchPage:MIN(pager.currentPage, pages.count-1) animated:NO];
}


- (void)_loadPage:(NSUInteger)page {
    UIView *pageView = [pages objectAtIndex:page];
    if ([pageView isKindOfClass:[NSNull class]]) {
        pageView = [dataSource viewForPage:page inPager:self];
        if (pageView) {
            [pages replaceObjectAtIndex:page withObject:pageView];
            CGSize pageSize = scroll.frame.size; 
            pageView.frame = CGRectMake(pageSize.width * page, 0, pageSize.width, pageSize.height);
            [scroll addSubview:pageView];
        }
    }
}


- (void)_unloadPage:(NSUInteger)page {
    UIView *pageView = [pages objectAtIndex:page];
    if (![pageView isKindOfClass:[NSNull class]]) {
        [pageView removeFromSuperview];
        [pages replaceObjectAtIndex:page withObject:[NSNull null]];
    }
}


- (void)setActivePage:(NSUInteger)page {
    if (page >= pages.count) return;

    NSUInteger min = page > loadMargin ? page - loadMargin : 0;
    NSUInteger max = MIN(page + loadMargin + 1, pages.count);

    [self _loadPage:page];
    for (NSUInteger i = min; i < max; i++) {
        [self _loadPage:i];
    }

    for (NSUInteger i = minLoadedPage; i < min; i++) {
        [self _unloadPage:i];
    }
    for (NSUInteger i = MIN(pages.count - 1, max); i < maxLoadedPage; i++) {
        [self _unloadPage:i];
    }

    minLoadedPage = min;
    maxLoadedPage = max;
    
    [buttonLeft setEnabled:page != 0];
    [buttonRight setEnabled:page < pages.count-1];

    if (page != pager.currentPage) {
        pager.currentPage = page;
        [pager updateCurrentPageDisplay];
        [delegate pagerController:self didSwitchToPage:pager.currentPage];
    }
}


- (void)switchPage:(NSUInteger)page animated:(BOOL)animated {
    if (page >= pages.count) return;

    CGSize pageSize = scroll.frame.size;
    CGPoint offset = CGPointMake(page * pageSize.width, scroll.contentOffset.y);
    [scroll setContentOffset:offset animated:animated];
    
    animating = animated;

    if (!animated) {
        [self setActivePage:page];
    }
}


- (void)updateCurrentPage {
    CGFloat pageWidth = self.view.bounds.size.width;
    NSUInteger page = scroll.contentOffset.x / pageWidth;
    if (scroll.contentOffset.x - (page * pageWidth) > pageWidth / 2) {
        page++;
    }
    [self setActivePage:page];
}


- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    if (!decelerate) {
        [self updateCurrentPage];
    }
}


- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    [self updateCurrentPage];
}


- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView {
    [self updateCurrentPage];
    animating = NO;
}


- (void)dealloc {
    [scroll release];
    [pager release];
    [pages release];
    [buttonLeft release];
    [buttonRight release];
    [super dealloc];
}


@end
