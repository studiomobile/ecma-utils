#import <UIKit/UIKit.h>

@interface TextEditController : UIViewController<UITextViewDelegate> {
	UITextView *textView;
	NSString *title;
	id dataSource;
	NSString *keyPath;
	
	BOOL navigationBarWasHidden;
}
@property (assign) id dataSource;
@property (retain) NSString *keyPath;

- (id)initWithTitle:(NSString*)title;

@end
