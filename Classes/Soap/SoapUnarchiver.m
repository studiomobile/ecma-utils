#import "TouchXML.h";
#import "NSError+Utils.h"
#import "SoapEntityProto.h"
#import "SoapUnarchiver.h"
#import "NSError+Utils.h"

@interface SoapDeenveloperContext : NSObject
{
	CXMLNode* node;
	id type;

	NSDictionary* nodesCache;		
}

@property(retain) CXMLNode* node;
@property(retain) id type;
@property(retain) NSDictionary* nodesCache;

-(id)initWithNode: (CXMLNode*)_node type: (id)_type;
+(SoapDeenveloperContext*) contextWithNode: (CXMLNode*)node type: (id)type;

-(id)typeForKey: (NSString*)key;
-(id)isManyForKey: (NSString*)key;
-(NSArray*)nodesNamed: (NSString*)key namespace: (NSString*)ns;

@end

@implementation SoapDeenveloperContext

@synthesize node;
@synthesize type;
@synthesize nodesCache;

-(void)dealloc{
	[node release];
	[type release];
	[nodesCache release];
	[super dealloc];
}

-(id)initWithNode: (CXMLNode*)_node type: (id)_type{
	if(![super init])
		return nil;	
	
	self.node = _node;
	self.type = _type;	
	
	return self;
}

+(SoapDeenveloperContext*) contextWithNode: (CXMLNode*)node type: (id)type{
	SoapDeenveloperContext* obj = [[[SoapDeenveloperContext alloc] initWithNode: node type:type]autorelease];
	return obj;
}

-(id)typeForKey: (NSString*)key{
	return [type typeForKey:key];	
}

-(id)isManyForKey: (NSString*)key{
	if(![type respondsToSelector: @selector(isManyForKey:)])
		return NO;
	
	return [type isManyForKey:key];
}

-(NSArray*)nodesNamed: (NSString*)key namespace: (NSString*)ns{
	NSError* error = nil;
	NSDictionary* mappings =  [NSDictionary dictionaryWithObject: ns forKey: @"ns"];
	NSString* xpath = [NSString stringWithFormat: @"ns:%@", key];
	NSArray* nodes = [node nodesForXPath:xpath namespaceMappings: mappings error:&error];
	if(error){
		@throw error;
	}
	
	return nodes;	
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

@interface PseudoSoapEntity : NSObject
{	
	id type;
	BOOL isMany;
}

@property(retain) id type;
@property(assign) BOOL isMany;

@end

@implementation PseudoSoapEntity

@synthesize type;
@synthesize isMany;

-(void)dealloc{
	[type release];
	[super dealloc];
}

-(id)typeForKey: (NSString*)key{
	if([[type soapName] isEqual:key]) return type;
	return nil;
}

-(BOOL)isManyForKey: (NSString*)key{
	return isMany;
}

@end

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

@interface SoapUnarchiver ()

@property(readonly) SoapDeenveloperContext* nodeContext;

-(id)initWithXmlString: (NSString*)xml;
-(void)pushContext: (SoapDeenveloperContext*)ctx;
-(void)popContext;

@property(retain) NSArray* contextStack;

@end


@implementation SoapUnarchiver

@synthesize contextStack;
@dynamic nodeContext;

+(SoapUnarchiver*) soapUnarchiverWithXmlString: (NSString*)xmlString{
	return [[[[self class]alloc]initWithXmlString:xmlString]autorelease];
}

+(SoapUnarchiver*) soapUnarchiverWithData: (NSData*)data{
	NSString* xmlString = [[[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding]autorelease];
	return [self soapUnarchiverWithXmlString:xmlString];
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
	[contextStack release];
	[xml release];
	[super dealloc];
}

#pragma mark private

-(void)pushContext: (SoapDeenveloperContext*)ctx{
	[contextStack addObject:ctx];
}

-(void)popContext{
	[contextStack removeLastObject];	
}

-(void)setInitialContext: (SoapDeenveloperContext*)ctx{
	self.contextStack = [NSMutableArray arrayWithObject:ctx];
}

-(SoapDeenveloperContext*)nodeContext{
	return [contextStack lastObject];
}

-(NSString*)decodeStringForKey:(NSString*)key{
	CXMLNode* node = [self.nodeContext nodeNamed:key];	
	return [node stringValue];	
}

-(NSDate*)decodeDateForKey:(NSString*)key{
	CXMLNode* node = [self.nodeContext nodeNamed:key];	
	
	NSString* stringDate = [node stringValue];
	
	NSDateFormatter *dateFormat = [[NSDateFormatter new]autorelease];
	if([stringDate rangeOfString: @"T"].location == NSNotFound){
		[dateFormat setDateFormat: @"yyyy-MM-dd" ];
	}else{
		[dateFormat setDateFormat:@"yyyy-MM-dd'T'HH:mm:SSSS"];
	}	

	NSDate* date = [dateFormat dateFromString: [node stringValue]];
	return date;
}

-(id)decodeSoapEntityForKey: (NSString*)key{
	id type = [self.nodeContext typeForKey:key];
	NSArray* nodes = [self.nodeContext nodesNamed: key namespace: [type soapNamespace]];
	NSMutableArray* objects = [NSMutableArray array];
	for(CXMLNode* n in nodes){
		SoapDeenveloperContext* newContext = [SoapDeenveloperContext contextWithNode:n type:type];
		[self pushContext: newContext];
		id obj = [type alloc];
		[obj initWithCoder: self];
		[self popContext];
		[objects addObject: obj];
		[obj release];
	}
	
	if([self.nodeContext isManyForKey: key]){
		return [objects copy];
	}else{
		return objects.count ? [objects objectAtIndex:0] : nil;
	}
}


#pragma mark utility

-(id) decodeBodyObjectOfType: (id)type{	
	NSDictionary* mappings = [NSDictionary dictionaryWithObject:@"http://www.w3.org/2003/05/soap-envelope" forKey: @"env"];
	NSString* xpath = [NSString stringWithString:@"env:Envelope/env:Body"];
	NSError* error = nil;
	NSArray* nodes = [xml nodesForXPath:xpath namespaceMappings:mappings error:&error];
	if(error){
		@throw error;
	}
	CXMLNode* root = [nodes lastObject];	 
	
	PseudoSoapEntity* initial = [[PseudoSoapEntity new]autorelease];
	initial.type = type;
	initial.isMany = NO;
	
	SoapDeenveloperContext* ctx = [SoapDeenveloperContext contextWithNode:root type:initial];
	[self setInitialContext: ctx];
	
	return [self decodeObjectForKey: [type soapName]];
}

#pragma mark NSCoder

- (id)decodeObjectForKey:(NSString *)key{
	id type = [self.nodeContext typeForKey:key];
	if(!type){
		@throw [NSError errorWithDomain:@"SoapUnarchiving" code:1 description: [NSString stringWithFormat: @"Unspecified type for key '%@'", key]];	
	}
	
	if(type == [NSString class]){
		return [self decodeStringForKey:key];
	}else if(type == [NSDate class]){
		return [self decodeDateForKey:key];
	}else if([type conformsToProtocol: @protocol(SoapEntityProto)]){
		return [self decodeSoapEntityForKey: key];
	}else{
		@throw [NSError errorWithDomain:@"SoapUnarchiving" code:2 description: [NSString stringWithFormat: @"Don't know how to decode type '%@'", type]];	
	}
}

- (BOOL)decodeBoolForKey:(NSString *)key{
	CXMLNode* node = [self.nodeContext nodeNamed:key];	
	return [[node stringValue] boolValue];
}

- (int)decodeIntForKey:(NSString *)key{
	CXMLNode* node = [self.nodeContext nodeNamed:key];	
	return [[node stringValue] intValue];
}

- (int32_t)decodeInt32ForKey:(NSString *)key{
	CXMLNode* node = [self.nodeContext nodeNamed:key];	
	return [[node stringValue] intValue];	
}

- (int64_t)decodeInt64ForKey:(NSString *)key{
	CXMLNode* node = [self.nodeContext nodeNamed:key];	
	return [[node stringValue] longLongValue];
}


- (float)decodeFloatForKey:(NSString *)key{
	CXMLNode* node = [self.nodeContext nodeNamed:key];	
	return [[node stringValue] floatValue];
}

- (double)decodeDoubleForKey:(NSString *)key{
	CXMLNode* node = [self.nodeContext nodeNamed:key];	
	return [[node stringValue] doubleValue];
}

- (NSInteger)versionForClassName:(NSString *)className{
	Class c = NSClassFromString(className);
	int ver = [c version];
	return ver;
}


@end
