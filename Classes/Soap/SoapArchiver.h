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

-(void)encodeObject: (id)objv forKey:(NSString*)key namespace:(NSString*)ns;
-(void)encodeHeader: (id)objv;

@end
