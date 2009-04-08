#import <Foundation/Foundation.h>
#import "SoapEntityProto.h"

@interface SoapCustomEntityType : NSObject<SoapEntityProto>
{
	NSString* namespace;
	NSString* name;
	
	NSMutableArray* fields;
}

@property(retain) 	NSString* name;
@property(retain) 	NSString* namespace;
@property(readonly) NSArray* fields;

-(void) addBoolForKey: (NSString*)key;
-(void) addIntForKey: (NSString*)key;
-(void) addInt32ForKey: (NSString*)key;
-(void) addInt64ForKey: (NSString*)key;
-(void) addFloatForKey: (NSString*)key;
-(void) addDoubleForKey: (NSString*)key;
-(void) addStringForKey: (NSString*)key;
-(void) addDateForKey: (NSString*)key;
-(void) addObjectOfType: (id)type forKey: (NSString*)key;			

@end

////////////////////////////////////////////////////////////////////////////////////

@interface SoapCustomEntity : NSObject<NSCoding, SoapEntityProto> {
	SoapCustomEntityType* type;	
	NSMutableDictionary* valueByKey;
}

@property(retain) NSString* name;
@property(retain) NSString* namespace;

-(void) setBool: (BOOL)val forKey: (NSString*)key;
-(void) setInt: (int)val forKey: (NSString*)key;	
-(void) setInt32: (int)val forKey: (NSString*)key;
-(void) setInt64: (int)val forKey: (NSString*)key;
-(void) setFloat: (int)val forKey: (NSString*)key;
-(void) setDouble: (double)val forKey: (NSString*)key;
-(void) setString: (NSString*)val forKey: (NSString*)key;
-(void) setDate: (NSDate*)val forKey: (NSString*)key;
-(void) setObject: (id)val forKey: (NSString*)key;

-(id) objectForKey: (NSString*)key;

@end
