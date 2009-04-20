#import "SoapCustomEntity.h"
#import "NSError+Utils.h"

@interface SoapCustomEntity ()

@property(retain, readwrite) SoapCustomEntityType* type;

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
	eTypeCode typeCode;
	BOOL isMany;
}

@property(retain) NSString* name;
@property(retain) id type;
@property(assign) BOOL isMany;
@property(assign) eTypeCode typeCode;

+(CustomFieldDescriptor*) customFieldWithName: (NSString*)name typeCode: (eTypeCode)tc;

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

-(NSString*)typeNameForTypeCode: (eTypeCode)tc{
	switch (tc) {
		case tcBool:
			return @"bool";
		case tcInt:
			return @"int";
		case tcInt32:
			return @"int32";
		case tcInt64:
			return @"int64";
		case tcFloat:
			return @"float";
		case tcDouble:
			return @"double";
		case tcObject:
		default:
			return nil;
	}
}

-(void)setTypeCode:(eTypeCode)tc{
	typeCode = tc;
	id typename = [self typeNameForTypeCode: tc];
	if(typename)
		self.type = typename;
}

+(CustomFieldDescriptor*) customFieldWithName: (NSString*)name typeCode: (eTypeCode)tc{
	CustomFieldDescriptor* inst = [[CustomFieldDescriptor new]autorelease];
	inst.name = name;
	inst.typeCode = tc;
	
	return inst;
}

-(void)encodeValue: (id)val withCoder: (NSCoder*)coder{
	if(isMany){
		[coder encodeObject:val forKey:name];
		return;
	}
	
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
	if(isMany){
		return [coder decodeObjectForKey:name];	
	}
	
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

+(SoapCustomEntityType*)soapCustomEntityTypeNamed: (NSString*)name namespace: (NSString*)namespace{
	return [[[[self class]alloc] initWithName: name namespace: namespace]autorelease];
}

-(id)initWithName: (NSString*)_name namespace: (NSString*)_namespace{
	if(![self init]){
		return nil;
	}
	
	self.name = _name;
	self.namespace = _namespace;
	
	return self;
}

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

-(CustomFieldDescriptor*)addFieldNamed: (NSString*)_name typeCode: (eTypeCode)tc{
	CustomFieldDescriptor* field = [CustomFieldDescriptor customFieldWithName:_name typeCode:tc];
	[fields addObject:field];
	return field;
}

-(void) addBoolForKey: (NSString*)key{
	[self addFieldNamed:key typeCode:tcBool];
}

-(void) addIntForKey: (NSString*)key;{
	[self addFieldNamed:key typeCode:tcInt];
}

-(void) addInt32ForKey: (NSString*)key;{
	[self addFieldNamed:key typeCode:tcInt32];
}

-(void) addInt64ForKey: (NSString*)key;{
	[self addFieldNamed:key typeCode:tcInt64];
}

-(void) addFloatForKey: (NSString*)key{
	[self addFieldNamed:key typeCode:tcFloat];
}

-(void) addDoubleForKey: (NSString*)key{
	[self addFieldNamed:key typeCode:tcDouble];
}

-(void) addStringForKey: (NSString*)key{
	[self addObjectOfType:[NSString class] forKey:key];
}

-(void) addDateForKey: (NSString*)key{
	[self addObjectOfType:[NSDate class] forKey:key];
}

-(void) addObjectOfType: (id)type forKey: (NSString*)key{
	[self addFieldNamed:key typeCode:tcObject].type = type;
}

-(void) addObjectOfType: (id)type{
	[self addObjectOfType:type forKey:[type soapName]];
}




-(void) addManyBoolsForKey: (NSString*)key{
	[self addFieldNamed:key typeCode:tcBool].isMany = YES;
}

-(void) addManyIntsForKey: (NSString*)key;{
	[self addFieldNamed:key typeCode:tcInt].isMany = YES;
}

-(void) addManyInt32sForKey: (NSString*)key;{
	[self addFieldNamed:key typeCode:tcInt32].isMany = YES;
}

-(void) addManyInt64sForKey: (NSString*)key;{
	[self addFieldNamed:key typeCode:tcInt64].isMany = YES;
}

-(void) addManyFloatsForKey: (NSString*)key{
	[self addFieldNamed:key typeCode:tcFloat].isMany = YES;
}

-(void) addManyDoublesForKey: (NSString*)key{
	[self addFieldNamed:key typeCode:tcDouble].isMany = YES;
}

-(void) addManyStringsForKey: (NSString*)key{
	[self addManyObjectsOfType:[NSString class] forKey:key];
}

-(void) addManyDatesForKey: (NSString*)key{
	[self addManyObjectsOfType:[NSDate class] forKey:key];
}

-(void) addManyObjectsOfType: (id)type forKey: (NSString*)key{
	CustomFieldDescriptor* f = [self addFieldNamed:key typeCode:tcObject];
	f.type = type;
	f.isMany = YES;
}

-(void) addManyObjectsOfType: (id)type{
	[self addManyObjectsOfType:type forKey: [type soapName]];	 
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

@implementation SoapCustomEntityType (Utils)

-(SoapCustomEntityType*)addObjectNamed: (NSString*)_name namespace: (NSString*)_namespace{
	SoapCustomEntityType* innerType = [SoapCustomEntityType soapCustomEntityTypeNamed:_name namespace:_namespace];
	[self addObjectOfType:innerType];
	return innerType;
}

-(SoapCustomEntityType*)addManyObjectsNamed: (NSString*)_name namespace: (NSString*)_namespace{
	SoapCustomEntityType* innerType = [SoapCustomEntityType soapCustomEntityTypeNamed:_name namespace:_namespace];
	[self addManyObjectsOfType:innerType];
	return innerType;	
}

@end

//////////////////////////////////////////////////////////////////////

@implementation SoapCustomEntity

@synthesize type;
@dynamic name;
@dynamic namespace;

+(SoapCustomEntity*)soapCustomEntityNamed: (NSString*)name namespace: (NSString*)namespace{
	return [[[[self class]alloc] initWithName: name namespace: namespace]autorelease];
}

-(id)initWithName: (NSString*)_name namespace: (NSString*)_namespace{
	if(![self init]){
		return nil;
	}
	
	self.name = _name;
	self.namespace = _namespace;
	
	return self;
}

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

-(void) setInt64: (long long)val forKey: (NSString*)key{
	[valueByKey setObject:[NSNumber numberWithLongLong:val] forKey:key];
	[type addInt64ForKey:key];		
}

-(void) setFloat: (float)val forKey: (NSString*)key{
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

-(void) setObject: (id)val{	
	id valType = [val respondsToSelector:@selector(soapClass)] ? [val soapClass] : [val class];	
	[self setObject:val forKey:[valType soapName]];
}





-(void) setManyBools: (NSArray*)val forKey: (NSString*)key{
	[valueByKey setObject: val forKey:key];
	[type addManyBoolsForKey:key];	
}

-(void) setManyInts: (NSArray*)val forKey: (NSString*)key{
	[valueByKey setObject: val forKey:key];
	[type addManyIntsForKey:key];		
}

-(void) setManyInt32s: (NSArray*)val forKey: (NSString*)key{
	[valueByKey setObject: val forKey:key];
	[type addManyInt32sForKey:key];		
}

-(void) setManyInt64s: (NSArray*)val forKey: (NSString*)key{
	[valueByKey setObject: val forKey:key];
	[type addManyInt64sForKey:key];		
}

-(void) setManyFloats: (NSArray*)val forKey: (NSString*)key{
	[valueByKey setObject: val forKey:key];
	[type addManyFloatsForKey:key];	
}

-(void) setManyDoubles: (NSArray*)val forKey: (NSString*)key{
	[valueByKey setObject: val forKey:key];
	[type addManyDoublesForKey:key];
}

-(void) setManyStrings: (NSArray*)val forKey: (NSString*)key{
	[valueByKey setObject: val forKey:key];
	[type addManyStringsForKey:key];	
}

-(void) setManyDates: (NSArray*)val forKey: (NSString*)key{
	[valueByKey setObject: val forKey:key];
	[type addManyDatesForKey:key];		
}

-(void) setManyObjects: (NSArray*) val ofType: (id)valType forKey: (NSString*)key{
	[valueByKey setObject:val forKey:key];
	[type addManyObjectsOfType:valType forKey:key];			
}

-(void) setManyObjects: (NSArray*) val ofType: (id)valType{
	[self setManyObjects:val ofType:valType forKey: [valType soapName]];
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
	@throw [NSError errorWithDomain:@"RuntimeError" code:2 description:@"Should not call"];	
}


@end


@implementation SoapCustomEntity (Utils)

-(id)objectForPath: (NSArray*)path{
	SoapCustomEntity* last = self;
	for(NSString* key in path){
		last = [last objectForKey:key];
		if(!last){
			@throw [NSError errorWithDomain:@"RuntimeError" code:3 description:[NSString stringWithFormat:@"No object for key '%@' found", key]];
		}		
	}
	
	return last;
}

@end
