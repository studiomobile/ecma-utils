#import <UIKit/UIKit.h>

@interface UIWebView(Utils)

@property (readonly, nonatomic) BOOL loaded;

- (void)loadLocalHTMLString:(NSString*)htmlString;
- (void)loadLocalHTMLFileFromMainBundle:(NSString*)name;
- (void)loadLocalHTMLFileFromMainBundle:(NSString*)name directory:(NSString*)directory;

@end
