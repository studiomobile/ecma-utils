#import "CustomSoapEntity.h"


@interface CustomFieldDescriptor : NSObject
{
	NSString* name;
	id type;
	BOOL isMany;
	SEL encodeSelector;
}

@property(retain) NSString* name;
@property(retain) type;
@property(assign) isMany;
@property(assign) encodeSelector;

-(void)encodeValue: (id)val withCoder: (NSCoder*)coder;

@end

@implementation CustomFieldDescriptor

@synthesize name;
@synthesize type;
@synthesize isMany;
@synthesize encodeSelector;

-(void)dealloc{
	[name release];
	[type release];
	[super dealloc];
}

-(void)encodeValue: (id)val withCoder: (NSCoder*)coder{
	[coder performSelector:encodeSelector withObject:val withObject:name];
}

@end



//////////////////////////////////////////////////////////////////////

@interface CustomSoapEntityType : NSObject
{
	NSString* namespace;
	NSString* name;

	NSMutableArray* fields;
}

@property(retain) 	NSString* name;
@property(retain) 	NSString* namespace;
@property(readonly) NSArray* fields;

@end

@implementation CustomSoapEntityType

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

-(CustomFieldDescriptor*)fieldForKey: (NSString*)key{
	for(CustomFieldDescriptor* d in fields){
		if([d.name isEqual:key]){
			return d;
		}			
	}
	
	return nil;
}

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

@end

//////////////////////////////////////////////////////////////////////

@implementation CustomSoapEntity

@dynamic name;
@dynamic namespace;

-(id)init{
	if(![super init])
		return nil;
	
	type = [CustomSoapEntityType new];
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

-(void) setBool: (BOOL)val forKey: (NSString*)key{
	[valueByKey setObject:[NSNumber numberWithBool:val] forKey:key];
	CustomFieldDescriptor* descr = [[CustomFieldDescriptor new]autorelease];
	
}

-(void) setInt: (int)val forKey: (NSString*)key;{
	
}

-(void) setDouble: (double)val forKey: (NSString*)key{
	
}

-(void) setString: (NSString*)val forKey: (NSString*)key{
	
}

-(void) setDate: (NSDate*)val forKey: (NSString*)key{
	
}

-(void) setObject: (id)val forKey: (NSString*)key{
	
}


#pragma mark NSCoding

- (void)encodeWithCoder:(NSCoder *)aCoder{
	for(CustomFieldDescriptor* d in type.fields){
		[d encodeValue: [valueByKey objectForKey:[d.name]] withCoder: aCoder];
	}
}


- (id)initWithCoder:(NSCoder *)aDecoder{
	return self;
}


@end
