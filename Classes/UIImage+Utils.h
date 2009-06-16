#import <UIKit/UIKit.h>

@interface UIImage (Utils)

+ (UIImage*) imageFromURL: (NSString*) urlString;
- (UIImage*)scaleToSize:(CGSize)size;
- (UIImage*)fitToSize:(CGSize)size;
- (UIImage*)cropToRect:(CGRect)rect;
- (UIImage*)flipHorizontal;

@end
