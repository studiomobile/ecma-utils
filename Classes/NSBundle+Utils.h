#import <Foundation/Foundation.h>


@interface NSBundle(Utils)

- (id)loadPlist:(NSString*)name errorDescription:(NSString**)errorDescription;

@end
