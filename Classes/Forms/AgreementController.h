#import <UIKit/UIKit.h>

@interface AgreementController : UIViewController {
    UIWebView *webView;
	NSString *title;
	id dataSource;
	NSString *keyPath;
	
    NSString *html;
	BOOL navigationBarWasHidden;
}
@property (assign) id dataSource;
@property (retain) NSString *keyPath;
@property (retain) NSString *html;

- (id)initWithTitle:(NSString*)title;

@end
