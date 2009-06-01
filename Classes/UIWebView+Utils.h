#import <UIKit/UIKit.h>

@interface UIWebView(Utils)

- (void)loadLocalHTMLString:(NSString*)htmlString;
- (void)loadLocalHTMLFileFromMainBundle:(NSString*)name;
- (void)loadLocalHTMLFileFromMainBundle:(NSString*)name directory:(NSString*)directory;

@end
