#import <Foundation/Foundation.h>
#import "SoapEntityProto.h"

@class CustomSoapEntityType;

@interface CustomSoapEntity : NSObject<NSCoding> {
	CustomSoapEntityType* type;
	
	NSMutableDictionary* valueByKey;
}

@property(retain) NSString* name;
@property(retain) NSString* namespace;

-(void) setBool: (BOOL)val forKey: (NSString*)key;
-(void) setInt: (int)val forKey: (NSString*)key;	
-(void) setDouble: (double)val forKey: (NSString*)key;
-(void) setString: (NSString*)val forKey: (NSString*)key;
-(void) setDate: (NSDate*)val forKey: (NSString*)key;
-(void) setObject: (id)val forKey: (NSString*)key;

@end
