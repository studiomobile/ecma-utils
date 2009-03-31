#import <Foundation/Foundation.h>
#import "SoapEntityProto.h"

@class XMLWriter;

@interface SoapArchiver : NSCoder {
	XMLWriter* writer;
	
	BOOL hasHeader;
	BOOL hasBody;
	int state;
}

@property(readonly) NSString* message;

+(SoapArchiver*)soapArchiver;

-(void)encodeHeader: (id<SoapEntityProto>)objv;
-(void)encodeHeader: (id<SoapEntityProto>)objv forKey: (NSString*)key;

-(void)encodeBody: (id<SoapEntityProto>)objv;
-(void)encodeBody: (id<SoapEntityProto>)objv forKey: (NSString*)key;

@end
