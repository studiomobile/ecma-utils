#import "SoapCustomEntity.h"
#import "NSError+Utils.h"

@interface SoapCustomEntity ()

@property(retain) SoapCustomEntityType* type;

@end


///////////////////////////////////////////////////////////////////////////
typedef enum eTypeCode_tag{
	tcBool,
	tcInt,
	tcInt32,
	tcInt64,
	tcFloat,
	tcDouble,
	tcObject		
} eTypeCode;	

@interface CustomFieldDescriptor : NSObject
{
	NSString* name;
	id type;
	BOOL isMany;
	eTypeCode typeCode;
}

@property(retain) NSString* name;
@property(retain) id type;
@property(assign) BOOL isMany;
@property(assign) eTypeCode typeCode;

-(void)encodeValue: (id)val withCoder: (NSCoder*)coder;
-(id)decodeValueWithDecoder: (NSCoder*)coder;

@end

@implementation CustomFieldDescriptor

@synthesize name;
@synthesize type;
@synthesize isMany;
@synthesize typeCode;

-(void)dealloc{
	[name release];
	[type release];
	[super dealloc];
}

-(void)encodeValue: (id)val withCoder: (NSCoder*)coder{
	switch (typeCode) {
		case tcBool:
			[coder encodeBool:[val boolValue] forKey:name];
			return;
		 case tcInt:
			[coder encodeInt:[val intValue] forKey:name];
			return;
		case tcInt32:
			[coder encodeInt32:[val intValue] forKey:name];
			return;
		case tcInt64:
			[coder encodeInt64:[val longLongValue] forKey:name];
			return;
		case tcFloat:
			[coder encodeFloat:[val floatValue] forKey:name];
			return;
		case tcDouble:
			[coder encodeDouble:[val doubleValue] forKey:name];
			return;
		 case tcObject:
			[coder encodeObject:val forKey:name];
			return;
	 }
			 
}

-(id)decodeValueWithDecoder: (NSCoder*)coder{
	switch (typeCode) {
		case tcBool:
			return [NSNumber numberWithBool: [coder decodeBoolForKey:name]];
		case tcInt:
			return [NSNumber numberWithInt: [coder decodeIntForKey:name]];
		case tcInt32:
			return [NSNumber numberWithInt: [coder decodeInt32ForKey:name]];
		case tcInt64:
			return [NSNumber numberWithLongLong: [coder decodeInt64ForKey:name]];
		case tcFloat:
			return [NSNumber numberWithFloat: [coder decodeFloatForKey:name]];
		case tcDouble:
			return [NSNumber numberWithDouble: [coder decodeDoubleForKey:name]];
		case tcObject:
			return [coder decodeObjectForKey:name];
	}	
	
	return nil;
}


@end

//////////////////////////////////////////////////////////////////////

@implementation SoapCustomEntityType

@synthesize name;
@synthesize namespace;
@synthesize fields;

-(id)init{	
	if(![super init])
		return nil;
	
	fields = [NSMutableArray new];
	
	return self;
}

-(void)dealloc{
	[name release];
	[namespace release];
	[fields release];
	[super dealloc];
}

-(id)alloc{
	SoapCustomEntity* obj = [SoapCustomEntity alloc];
	obj.type = self;
	return obj;
}

-(CustomFieldDescriptor*)fieldForKey: (NSString*)key{
	for(CustomFieldDescriptor* d in fields){
		if([d.name isEqual:key]){
			return d;
		}			
	}
	
	return nil;
}

#pragma mark configuring

-(void) addBoolForKey: (NSString*)key{
	CustomFieldDescriptor* field = [[CustomFieldDescriptor new]autorelease];
	field.name = key;
	field.typeCode = tcBool;
	[fields addObject:field];
}

-(void) addIntForKey: (NSString*)key;{
	CustomFieldDescriptor* field = [[CustomFieldDescriptor new]autorelease];
	field.name = key;
	field.typeCode = tcInt;
	[fields addObject:field];	
}

-(void) addInt32ForKey: (NSString*)key;{
	CustomFieldDescriptor* field = [[CustomFieldDescriptor new]autorelease];
	field.name = key;
	field.typeCode = tcInt32;
	[fields addObject:field];	
}

-(void) addInt64ForKey: (NSString*)key;{
	CustomFieldDescriptor* field = [[CustomFieldDescriptor new]autorelease];
	field.name = key;
	field.typeCode = tcInt64;
	[fields addObject:field];	
}

-(void) addFloatForKey: (NSString*)key{
	CustomFieldDescriptor* field = [[CustomFieldDescriptor new]autorelease];
	field.name = key;
	field.typeCode = tcInt64;
	[fields addObject:field];	
}

-(void) addDoubleForKey: (NSString*)key{
	CustomFieldDescriptor* field = [[CustomFieldDescriptor new]autorelease];
	field.name = key;
	field.typeCode = tcDouble;
	[fields addObject:field];	
}

-(void) addStringForKey: (NSString*)key{
	[self addObjectOfType:[NSString class] forKey:key];
}

-(void) addDateForKey: (NSString*)key{
	[self addObjectOfType:[NSDate class] forKey:key];
}

-(void) addObjectOfType: (id)type forKey: (NSString*)key{
	CustomFieldDescriptor* field = [[CustomFieldDescriptor new]autorelease];
	field.name = key;
	field.type = type;
	field.typeCode = tcObject;
	[fields addObject:field];	
}

#pragma mark SoapEntityProto

-(NSString*) soapNamespace{
	return namespace;
}
-(NSString*) soapName{
	return name;
}

-(Class)typeForKey: (NSString*)key{
	return [self fieldForKey:key].type;
}

-(BOOL)isManyForKey: (NSString*)key{
	return [self fieldForKey:key].isMany;
}

// dummies to avoid compiler complains
+(NSString*) soapNamespace{
	@throw [NSError errorWithDomain:@"RuntimeError" code:1 description:@"Should not call"];
}

+(NSString*) soapName{
	@throw [NSError errorWithDomain:@"RuntimeError" code:1 description:@"Should not call"];	
}

@end

//////////////////////////////////////////////////////////////////////

@implementation SoapCustomEntity

@synthesize type;
@dynamic name;
@dynamic namespace;

-(id)init{
	if(![super init])
		return nil;
	
	type = [SoapCustomEntityType new];
	valueByKey = [NSMutableDictionary new];
	
	return self;
}

-(void)dealloc{
	[type release];
	[valueByKey release];	
	[super dealloc];
}

-(id)soapClass{
	return type;
}

-(NSString*)name{
	return type.name;
}

-(void)setName: (NSString*)name{
	type.name = name;
}

-(NSString*)namespace{
	return type.namespace;
}

-(void)setNamespace: (NSString*)namespace{
	type.namespace = namespace;	
}

-(id) objectForKey: (NSString*)key{
	return [valueByKey objectForKey:key];	
}

#pragma mark configuring

-(void) setBool: (BOOL)val forKey: (NSString*)key{
	[valueByKey setObject:[NSNumber numberWithBool:val] forKey:key];
	[type addBoolForKey:key];	
}

-(void) setInt: (int)val forKey: (NSString*)key{
	[valueByKey setObject:[NSNumber numberWithInt:val] forKey:key];
	[type addIntForKey:key];		
}

-(void) setInt32: (int)val forKey: (NSString*)key{
	[valueByKey setObject:[NSNumber numberWithInt:val] forKey:key];
	[type addInt32ForKey:key];		
}

-(void) setInt64: (int)val forKey: (NSString*)key{
	[valueByKey setObject:[NSNumber numberWithLongLong:val] forKey:key];
	[type addInt64ForKey:key];		
}

-(void) setFloat: (int)val forKey: (NSString*)key{
	[valueByKey setObject:[NSNumber numberWithFloat:val] forKey:key];
	[type addFloatForKey:key];	
}

-(void) setDouble: (double)val forKey: (NSString*)key{
	[valueByKey setObject:[NSNumber numberWithDouble:val] forKey:key];
	[type addDoubleForKey:key];
}

-(void) setString: (NSString*)val forKey: (NSString*)key{
	[valueByKey setObject:val forKey:key];
	[type addStringForKey:key];	
}

-(void) setDate: (NSDate*)val forKey: (NSString*)key{
	[valueByKey setObject:val forKey:key];
	[type addDateForKey:key];		
}

-(void) setObject: (id)val forKey: (NSString*)key{
	[valueByKey setObject:val forKey:key];
	id valType = [val respondsToSelector:@selector(soapClass)] ? [val soapClass] : [val class];	
	[type addObjectOfType:valType forKey:key];			
}

#pragma mark NSCoding

- (void)encodeWithCoder:(NSCoder *)aCoder{
	for(CustomFieldDescriptor* d in type.fields){
		[d encodeValue: [valueByKey objectForKey:d.name] withCoder: aCoder];
	}
}

- (id)initWithCoder:(NSCoder *)aDecoder{
	if(![super init])
		return nil;
	
	valueByKey = [NSMutableDictionary new];
	
	for(CustomFieldDescriptor* d in type.fields){
		id value = [d decodeValueWithDecoder:aDecoder];
		[valueByKey setObject:value forKey:d.name];		
	}	
	
	return self;
}

// dummies to avoid compiler complains
#pragma mark SoapEntityProto

+(NSString*) soapNamespace{
	@throw [NSError errorWithDomain:@"RuntimeError" code:1 description:@"Should not call"];
}

+(NSString*) soapName{
	@throw [NSError errorWithDomain:@"RuntimeError" code:1 description:@"Should not call"];	
}


@end
