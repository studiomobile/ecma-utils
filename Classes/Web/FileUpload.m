#import "FileUpload.h"
#import <UIKit/UIKit.h>

@implementation FileUpload

@synthesize data;
@synthesize fileName;
@synthesize contentType;


- (id)initWithData:(NSData*)_data fileName:(NSString*)_fileName contentType:(NSString*)_contentType {
	if (self = [super init]) {
		data = [_data retain];
		fileName = [_fileName retain];
		contentType = [_contentType retain];
	}
	return self;
}


+ (FileUpload*)fileUploadForJPEGImage:(UIImage*)image withFileName:(NSString*)filename quality:(float)quality {
    return [self fileUploadForData:UIImageJPEGRepresentation(image, quality) withFileName:filename contentType:@"image/jpeg"];
}


+ (FileUpload*)fileUploadForPNGImage:(UIImage*)image withFileName:(NSString*)filename {
    return [self fileUploadForData:UIImagePNGRepresentation(image) withFileName:filename contentType:@"image/png"];
}


+ (FileUpload*)fileUploadForData:(NSData*)data withFileName:(NSString*)filename contentType:(NSString*)contentType {
    return [[[FileUpload alloc] initWithData:data fileName:filename contentType:contentType] autorelease];
}


- (void)dealloc {
	[data release];
	[fileName release];
	[contentType release];
	[super dealloc];
}

@end
