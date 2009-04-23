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
@property(readonly) NSMutableArray* fields;

+(SoapCustomEntityType*)soapCustomEntityTypeNamed: (NSString*)name namespace: (NSString*)namespace;
-(id)initWithName: (NSString*)_name namespace: (NSString*)_namespace;

-(void) addBoolForKey: (NSString*)key;
-(void) addIntForKey: (NSString*)key;
-(void) addInt32ForKey: (NSString*)key;
-(void) addInt64ForKey: (NSString*)key;
-(void) addFloatForKey: (NSString*)key;
-(void) addDoubleForKey: (NSString*)key;
-(void) addStringForKey: (NSString*)key;
-(void) addDateForKey: (NSString*)key;
-(void) addObjectOfType: (id)type;
-(void) addObjectOfType: (id)type forKey: (NSString*)key;

-(void) addManyBoolsForKey: (NSString*)key;
-(void) addManyIntsForKey: (NSString*)key;
-(void) addManyInt32sForKey: (NSString*)key;
-(void) addManyInt64sForKey: (NSString*)key;
-(void) addManyFloatsForKey: (NSString*)key;
-(void) addManyDoublesForKey: (NSString*)key;
-(void) addManyStringsForKey: (NSString*)key;
-(void) addManyDatesForKey: (NSString*)key;
-(void) addManyObjectsOfType: (id)type;
-(void) addManyObjectsOfType: (id)type forKey: (NSString*)key;	

@end

@interface SoapCustomEntityType (Utils)

-(SoapCustomEntityType*)addObjectNamed: (NSString*)name namespace: (NSString*)namespace;
-(SoapCustomEntityType*)addManyObjectsNamed: (NSString*)name namespace: (NSString*)namespace;

@end


////////////////////////////////////////////////////////////////////////////////////

@interface SoapCustomEntity : NSObject<NSCoding, SoapEntityProto> {
	SoapCustomEntityType* type;	
	NSMutableDictionary* valueByKey;
}

@property(retain, readonly) SoapCustomEntityType* type;
@property(retain) NSString* name;
@property(retain) NSString* namespace;

+(SoapCustomEntity*)soapCustomEntityNamed: (NSString*)name namespace: (NSString*)namespace;
-(id)initWithName: (NSString*)_name namespace: (NSString*)_namespace;

-(void) setBool: (BOOL)val forKey: (NSString*)key;
-(void) setInt: (int)val forKey: (NSString*)key;	
-(void) setInt32: (int32_t)val forKey: (NSString*)key;
-(void) setInt64: (int64_t)val forKey: (NSString*)key;
-(void) setFloat: (float)val forKey: (NSString*)key;
-(void) setDouble: (double)val forKey: (NSString*)key;
-(void) setString: (NSString*)val forKey: (NSString*)key;
-(void) setDate: (NSDate*)val forKey: (NSString*)key;
-(void) setObject: (id)val;
-(void) setObject: (id)val forKey: (NSString*)key;

-(void) setManyBools: (NSArray*) val forKey: (NSString*)key;
-(void) setManyInts: (NSArray*) val forKey: (NSString*)key;	
-(void) setManyInt32s: (NSArray*) val forKey: (NSString*)key;
-(void) setManyInt64s: (NSArray*) val forKey: (NSString*)key;
-(void) setManyFloats: (NSArray*) val forKey: (NSString*)key;
-(void) setManyDoubles: (NSArray*) val forKey: (NSString*)key;
-(void) setManyStrings: (NSArray*) val forKey: (NSString*)key;
-(void) setManyDates: (NSArray*) val forKey: (NSString*)key;
-(void) setManyObjects: (NSArray*) val ofType: (id)valType;
-(void) setManyObjects: (NSArray*) val ofType: (id)valType forKey: (NSString*)key;

-(id) objectForKey: (NSString*)key;

@end

@interface SoapCustomEntity (Utils)

-(id)objectForPath: (NSArray*)path;

@end
