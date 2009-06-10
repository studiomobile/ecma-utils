#import "UIImage+Utils.h"
#import "CGGeometry+Utils.h"


@implementation UIImage  (Utils)

+ (UIImage*)imageFromURL:(NSString*)urlString{
	NSURL *url = [NSURL URLWithString:urlString];
	NSData *data = [NSData dataWithContentsOfURL:url];
	UIImage *img = [[[UIImage alloc] initWithData:data]autorelease];
	return img;	
}


- (UIImage*)scaleToSize:(CGSize)size {
	UIGraphicsBeginImageContext(size);
	
	CGContextRef context = UIGraphicsGetCurrentContext();
	CGContextTranslateCTM(context, 0.0, size.height);
	CGContextScaleCTM(context, 1.0, -1.0);
	
	CGContextDrawImage(context, CGRectMake(0.0f, 0.0f, size.width, size.height), self.CGImage);
	
	UIImage* scaledImage = UIGraphicsGetImageFromCurrentImageContext();
	
	UIGraphicsEndImageContext();
	
	return scaledImage;
}


- (UIImage*)fitToSize:(CGSize)size{
	CGSize newSize = CGSizeFitIntoSize(self.size, size);
	return [self scaleToSize:newSize];
}


- (UIImage*)cropToRect:(CGRect)rect {
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
 	CGContextTranslateCTM(context, 0.0, rect.size.height);
	CGContextScaleCTM(context, 1.0, -1.0);
    CGRect clippedRect = CGRectMake(0, 0, rect.size.width, rect.size.height);
    CGContextClipToRect(context, clippedRect);
    
    CGRect drawRect = CGRectMake(-rect.origin.x ,
                                 -(self.size.height - rect.size.height - rect.origin.y),
                                 self.size.width,
                                 self.size.height);
    
    CGContextDrawImage(context, drawRect, self.CGImage);
    
    UIImage *cropped = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return cropped;
}

@end
