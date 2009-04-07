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

-(void)encodeHeaderObject: (id<SoapEntityProto>)objv;
-(void)encodeHeaderObject: (id<SoapEntityProto>)objv forKey: (NSString*)key;

-(void)encodeBodyObject: (id<SoapEntityProto>)objv;
-(void)encodeBodyObject: (id<SoapEntityProto>)objv forKey: (NSString*)key;

@end
