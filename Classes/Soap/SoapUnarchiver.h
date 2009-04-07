#import <Foundation/Foundation.h>

@class CXMLDocument;
@class SoapUnarchiverContext;

@interface SoapUnarchiver : NSCoder{
	CXMLDocument* xml;		
	NSMutableArray* contextStack;
}

+(SoapUnarchiver*) soapUnarchiverWithXmlString: (NSString*)xmlString;
+(SoapUnarchiver*) soapUnarchiverWithData: (NSData*)data;

-(id) decodeBodyObjectOfType: (id)type;

@end
