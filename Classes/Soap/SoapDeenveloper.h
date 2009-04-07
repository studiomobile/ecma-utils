#import <Foundation/Foundation.h>

@class CXMLDocument;

@interface SoapDeenveloper : NSCoder{
	CXMLDocument* xml;		
	NSMutableArray* contextStack;
}

+(SoapDeenveloper*) soapDeenveloperWithXmlString: (NSString*)xmlString;
+(SoapDeenveloper*) soapDeenveloperWithData: (NSData*)data;

-(id) decodeBodyObjectOfType: (id)type;

@end
