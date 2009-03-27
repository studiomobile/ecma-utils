#import "TouchXML.h";
#import "NSError+Utils.h"
#import "SoapEntityProto.h"
#import "SoapUnarchiver.h"


@interface SoapUnarchiverContext : NSObject
{
	NSDictionary* mappings;
	CXMLNode* node;
	id<SoapEntityProto> obj;
	
	NSDictionary* nodesCache;	
}

@property(assign) NSDictionary* mappings;
@property(assign) CXMLNode* node;
@property(assign) id<SoapEntityProto> obj;
@property(retain) NSDictionary* nodesCache;

+(SoapUnarchiverContext*) contextWithObject: (id<SoapEntityProto>) _obj node: (CXMLNode*)_node mappings: (NSDictionary*)_mappings;

-(CXMLNode*)nodeNamed: (NSString*)name;

@end

@implementation SoapUnarchiverContext

@synthesize mappings;
@synthesize node;
@synthesize obj;
@synthesize nodesCache;

+(SoapUnarchiverContext*) contextWithObject: (id<SoapEntityProto>) _obj node: (CXMLNode*)_node mappings: (NSDictionary*)_mappings{
	SoapUnarchiverContext* inst = [[self new]autorelease];
	inst.mappings = _mappings;
	inst.node = _node;
	inst.obj = _obj;	
	
	return inst;
}

-(void)dealloc{
	[nodesCache release];	
	[super dealloc];
}

-(void)fillNodesCache{
	NSMutableDictionary* newCache = [NSMutableDictionary dictionary];
	for(CXMLNode* n in [node children]){
		if(n.kind == XML_ELEMENT_NODE){
			[newCache setValue:n forKey:n.name];			
		}
	}
	
	self.nodesCache = [newCache copy];
}

-(CXMLNode*)nodeNamed: (NSString*)name{
	if(!nodesCache){
		[self fillNodesCache];
	}
	
	return [nodesCache valueForKey:name];
}


@end


////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

@interface SoapUnarchiver ()

@property(retain) SoapUnarchiverContext* nodeContext;

-(id)initWithXmlString: (NSString*)xml;

@end


@implementation SoapUnarchiver

@synthesize nodeContext;

+(SoapUnarchiver*) soapUnarchiverWithXmlString: (NSString*)xmlString{
	return [[[[self class]alloc]initWithXmlString:xmlString]autorelease];
}

-(id)initWithXmlString: (NSString*)xmlString{
	if(![super init])
		return nil;
	
	NSError* error = nil;
	xml = [[CXMLDocument alloc] initWithXMLString:xmlString options:0 error:&error];
	if(error){
		[self release];
		return nil;
	}
	
	return self;
}

-(void)dealloc{
	[nodeContext release];
	[xml release];
	[super dealloc];
}

#pragma mark private

-(NSString*)decodeStringForKey:(NSString*)key{
	CXMLNode* node = [nodeContext nodeNamed:key];	
	return [node stringValue];	
}

-(NSDate*)decodeDateForKey:(NSString*)key{
	CXMLNode* node = [nodeContext nodeNamed:key];	
	NSDateFormatter *dateFormat = [[[NSDateFormatter alloc]
									initWithDateFormat:@"%1d/%1m/%Y" allowNaturalLanguage:NO]autorelease];
	NSDate* date = [dateFormat dateFromString: [node stringValue]];
	return date;
}


#pragma mark utility

-(NSArray*) decodeObjectsOfType: (Class)aClass forXpath:(NSString*)path namespaceMappings: (NSDictionary*)mappings{
	
	NSError* error = nil;
	NSArray* nodes = [xml nodesForXPath:path namespaceMappings: mappings error:&error];
	if(error){
		@throw error;
	}
	
	NSMutableArray* result = [NSMutableArray array];
	for(CXMLNode* node in nodes){
		id obj = [aClass alloc];
		self.nodeContext = [SoapUnarchiverContext contextWithObject: obj node:node mappings:mappings];		
		[obj initWithCoder:self];
		[result addObject:obj];
	}	   
	
	return [result copy];	
}

#pragma mark NSCoder

- (id)decodeObjectForKey:(NSString *)key{
	Class c = [nodeContext.obj typeForKey:key];
	if(!c){
		@throw [NSError errorWithDomain:@"SoapUnarchiving" code:1 description: [NSString stringWithFormat: @"Unspecified type for key '%@'", key]];	
	}
	
	if(c == [NSString class]){
		return [self decodeStringForKey:key];
	}else if(c == [NSDate class]){
		return [self decodeDateForKey:key];
	}else{
		@throw [NSError errorWithDomain:@"SoapUnarchiving" code:2 description: [NSString stringWithFormat: @"Don't know how to decode type '%@'", c]];	
	}
}

- (BOOL)decodeBoolForKey:(NSString *)key{
	CXMLNode* node = [nodeContext nodeNamed:key];	
	return [[node stringValue] boolValue];
}

- (int)decodeIntForKey:(NSString *)key{
	CXMLNode* node = [nodeContext nodeNamed:key];	
	return [[node stringValue] intValue];
}

- (float)decodeFloatForKey:(NSString *)key{
	CXMLNode* node = [nodeContext nodeNamed:key];	
	return [[node stringValue] floatValue];
}

- (double)decodeDoubleForKey:(NSString *)key{
	CXMLNode* node = [nodeContext nodeNamed:key];	
	return [[node stringValue] doubleValue];
}

@end
