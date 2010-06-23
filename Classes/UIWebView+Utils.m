#import "UIWebView+Utils.h"


@implementation UIWebView(Utils)

- (BOOL)loaded { return !self.loading && self.request; }

- (void)loadLocalHTMLString:(NSString*)htmlString {
	NSURL *baseURL = [NSURL fileURLWithPath:[[NSBundle mainBundle] bundlePath]];
	[self loadHTMLString:htmlString baseURL:baseURL];
}


- (void)loadLocalHTMLFileFromMainBundle:(NSString*)name {
	NSBundle *mainBundle = [NSBundle mainBundle];
	NSString *path = [mainBundle pathForResource:name ofType:@"html"];
	NSURL *baseURL = [NSURL fileURLWithPath:[mainBundle bundlePath]];
	[self loadHTMLString:[NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil] baseURL:baseURL];
}


- (void)loadLocalHTMLFileFromMainBundle:(NSString*)name directory:(NSString*)directory {
	NSBundle *mainBundle = [NSBundle mainBundle];
	NSString *path = [mainBundle pathForResource:name ofType:@"html" inDirectory:directory];
	NSURL *baseURL = [NSURL fileURLWithPath:[mainBundle bundlePath]];
	[self loadHTMLString:[NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil] baseURL:baseURL];
}

@end
