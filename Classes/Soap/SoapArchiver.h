#import <Foundation/Foundation.h>

@class XMLWriter;

@interface SoapArchiver : NSCoder {
	XMLWriter* writer;
	
	BOOL hasHeader;
	BOOL hasBody;
	int state;
}

@property(readonly) NSString* message;

+(SoapArchiver*)soapArchiver;

-(void)encodeHeader: (id)objv;
-(void)encodeHeader: (id)objv forKey: (NSString*)key;

-(void)encodeBody: (id)objv;
-(void)encodeBody: (id)objv forKey: (NSString*)key;

@end
