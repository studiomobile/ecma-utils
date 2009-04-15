#import <UIKit/UIKit.h>

@interface UIImage (Utils)

+ (UIImage*) imageFromURL: (NSString*) urlString;
- (UIImage*)scaleToSize:(CGSize)size;
- (UIImage*)fitToSize:(CGSize)size;

@end
