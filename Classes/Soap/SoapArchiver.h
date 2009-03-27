#import <Foundation/Foundation.h>

@class XMLWriter;

@interface SoapArchiver : NSCoder {
	XMLWriter* writer;
	
	BOOL hasHeader;
	BOOL hasBody;
	int state;
}

@property(readonly) NSString* message;

-(void)encodeObject: (id)objv forKey:(NSString*)key namespace:(NSString*)ns;
-(void)encodeHeader: (id)objv;

- (void)encodeString:(NSString*)str forKey:(NSString *)key;
- (void)encodeDate:(NSDate*)date forKey:(NSString *)key;

@end
