#import "UIImage+Utils.h"
#import "CGGeometry+Utils.h"

CGContextRef BeginBitmapContextWithSize(CGSize size) {
	UIGraphicsBeginImageContext(size);
	return UIGraphicsGetCurrentContext();
}


UIImage* EndBitmapContext() {
	UIImage* result = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	return result;
}


@implementation UIImage  (Utils)

+ (UIImage*)imageFromURL:(NSString*)urlString{
	NSURL *url = [NSURL URLWithString:urlString];
	NSData *data = [NSData dataWithContentsOfURL:url];
	UIImage *img = [[[UIImage alloc] initWithData:data]autorelease];
	return img;	
}


- (UIImage*)scaleToSize:(CGSize)size {
	CGContextRef context = BeginBitmapContextWithSize(size);
	CGContextTranslateCTM(context, 0.0, size.height);
	CGContextScaleCTM(context, 1.0, -1.0);
	
	CGContextDrawImage(context, CGRectMake(0.0f, 0.0f, size.width, size.height), self.CGImage);
	
	return EndBitmapContext();
}


- (UIImage*)fitToSize:(CGSize)size{
	CGSize newSize = CGSizeFitIntoSize(self.size, size);
	return [self scaleToSize:newSize];
}


- (UIImage*)cropToRect:(CGRect)rect {
	CGContextRef context = BeginBitmapContextWithSize(rect.size);
    
 	CGContextTranslateCTM(context, 0.0, rect.size.height);
	CGContextScaleCTM(context, 1.0, -1.0);
    CGRect clippedRect = CGRectMake(0, 0, rect.size.width, rect.size.height);
    CGContextClipToRect(context, clippedRect);
    
    CGRect drawRect = CGRectMake(-rect.origin.x ,
                                 -(self.size.height - rect.size.height - rect.origin.y),
                                 self.size.width,
                                 self.size.height);
    
    CGContextDrawImage(context, drawRect, self.CGImage);
    
    return EndBitmapContext();
}


- (UIImage*)flipHorizontal {
	CGContextRef context = BeginBitmapContextWithSize(self.size);
    CGContextTranslateCTM(context, self.size.width, self.size.height);
    CGContextScaleCTM(context, -1.0, -1.0);
    
    CGContextDrawImage(context, CGRectMake(0, 0, self.size.width, self.size.height), self.CGImage);

    return EndBitmapContext();
}


@end
