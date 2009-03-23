#import <Foundation/Foundation.h>

@class XMLWriter;

@interface SoapArchiver : NSCoder {
	XMLWriter* writer;
}

@property(readonly) NSString* result;

@end
