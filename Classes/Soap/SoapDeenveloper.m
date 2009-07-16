#import "TouchXML.h";
#import "NSError+Utils.h"
#import "SoapEntityProto.h"
#import "SoapDeenveloper.h"
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
-(NSString*)namespace;
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

-(NSString*)namespace{
	return [type soapNamespace];	 
}

-(NSArray*)nodesNamed: (NSString*)key namespace: (NSString*)ns{
	NSError* error = nil;
	
	NSMutableDictionary* mappings = [NSMutableDictionary dictionary];
	NSString* xpath;
	if(ns){
		[mappings setObject:ns forKey:@"ns"];
		xpath = [NSString stringWithFormat: @"ns:%@", key];
	}else{
		xpath = key;
	}
	
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
	id childType;
	BOOL isMany;
}

@property(retain) id childType;
@property(assign) BOOL isMany;

@end

@implementation PseudoSoapEntity

@synthesize childType;
@synthesize isMany;

-(void)dealloc{
	[childType release];
	[super dealloc];
}

-(id)typeForKey: (NSString*)key{
	if([[childType soapName] isEqual:key]) return childType;
	return nil;
}

-(BOOL)isManyForKey: (NSString*)key{
	return isMany;
}

@end

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

@interface SoapDeenveloper ()

@property(readonly) SoapDeenveloperContext* nodeContext;

-(id)initWithXmlString: (NSString*)xml;
-(void)pushContext: (SoapDeenveloperContext*)ctx;
-(void)popContext;

@property(retain) NSMutableArray* contextStack;

@end


@implementation SoapDeenveloper

@synthesize contextStack;

+(SoapDeenveloper*) soapDeenveloperWithXmlString: (NSString*)xmlString{
	return [[[[self class]alloc]initWithXmlString:xmlString]autorelease];
}

+(SoapDeenveloper*) soapDeenveloperWithData: (NSData*)data{
	NSString* xmlString = [[[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding]autorelease];
	return [self soapDeenveloperWithXmlString:xmlString];
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

-(id) privateDecodeBodyObjectOfType: (id)type isMany: (BOOL)many{	
	NSDictionary* mappings = [NSDictionary dictionaryWithObject:@"http://www.w3.org/2003/05/soap-envelope" forKey: @"env"];
	NSString* xpath = [NSString stringWithString:@"env:Envelope/env:Body"];
	NSError* error = nil;
	NSArray* nodes = [xml nodesForXPath:xpath namespaceMappings:mappings error:&error];
	if(error){
		@throw error;
	}
	CXMLNode* root = [nodes lastObject];	 
	
	PseudoSoapEntity* bodyEntity = [[PseudoSoapEntity new]autorelease];
	bodyEntity.childType = type;
	bodyEntity.isMany = many;
	
	SoapDeenveloperContext* ctx = [SoapDeenveloperContext contextWithNode:root type:bodyEntity];
	[self setInitialContext: ctx];
	
	return [self decodeObjectForKey: [type soapName]];
}

#pragma mark specialized decoding methods

-(id)decodeStringFromNode: (CXMLNode*)node type: (id)type{	
	return [node stringValue];		
}

-(id)decodeDateFromNode: (CXMLNode*)node type: (id)type{
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

-(id)decodeSoapEntityFromNode: (CXMLNode*)node type: (id)type{
	SoapDeenveloperContext* newContext = [SoapDeenveloperContext contextWithNode:node type:type];
	[self pushContext: newContext];
	id obj = [type alloc];
	[obj initWithCoder: self];
	[self popContext];
	return [obj autorelease];
}

-(id)decodePrimitiveTypeFromNode: (CXMLNode*)node type: (id)type{
	if([type isEqual:@"bool"]){
		return [NSNumber numberWithBool: [[node stringValue] boolValue]];
	}else if([type isEqual:@"int"]){
		return [NSNumber numberWithInt:[[node stringValue] intValue]];
	}else if([type isEqual:@"int32"]){
		return [NSNumber numberWithInt:[[node stringValue] intValue]];
	}else if([type isEqual:@"int64"]){
		return [NSNumber numberWithLongLong:[[node stringValue] longLongValue]];
	}else if([type isEqual:@"float"]){
		return [NSNumber numberWithFloat:[[node stringValue] floatValue]];
	}else if([type isEqual:@"double"]){
		return [NSNumber numberWithDouble:[[node stringValue] doubleValue]];
	}else{
		@throw [NSError errorWithDomain:@"DecodingSoapMessage" code:1 description: [NSString stringWithFormat: @"Invalid primitive type '%@'", type]];			
	}		
}

#pragma mark 

-(id)decodeObjectsForKey: (NSString*)key namespace: (NSString*)ns decodingMethod: (SEL)decodingMethod{
	id type = [self.nodeContext typeForKey:key];
	
	NSArray* nodes = [self.nodeContext nodesNamed: key namespace: ns];
	NSMutableArray* objects = [NSMutableArray array];
	for(CXMLNode* n in nodes){
		id obj = [self performSelector:decodingMethod withObject:n withObject:type];
		if(obj){
			[objects addObject: obj];	
		}		
	}
	
	if([self.nodeContext isManyForKey: key]){
		return [objects copy];
	}else{
		return objects.count ? [objects objectAtIndex:0] : nil;
	}	
}

#pragma mark utility

-(id) decodeBodyObjectOfType: (id)type{	
	return [self privateDecodeBodyObjectOfType: type isMany: NO];
}

-(NSArray*) decodeBodyObjectsOfType: (id)type{	
	return [self privateDecodeBodyObjectOfType: type isMany: YES];
}

#pragma mark NSCoder

- (id)decodeObjectForKey:(NSString *)key{
	id type = [self.nodeContext typeForKey:key];
	if(!type){
		@throw [NSError errorWithDomain:@"SoapUnarchiving" code:1 description: [NSString stringWithFormat: @"Unspecified type for key '%@'", key]];	
	}
	
	if(type == [NSString class]){
		return [self decodeObjectsForKey:key namespace:[self.nodeContext namespace] decodingMethod:@selector(decodeStringFromNode:type:)];
	}else if(type == [NSDate class]){
		return [self decodeObjectsForKey:key namespace:[self.nodeContext namespace] decodingMethod:@selector(decodeDateFromNode:type:)];
	}else if([type isKindOfClass:[NSString class]]){
		return [self decodeObjectsForKey:key namespace:[self.nodeContext namespace] decodingMethod:@selector(decodePrimitiveTypeFromNode:type:)];
	}else if([type conformsToProtocol: @protocol(SoapEntityProto)]){
		return [self decodeObjectsForKey:key namespace:[type soapNamespace] decodingMethod:@selector(decodeSoapEntityFromNode:type:)];
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

- (BOOL)allowsKeyedCoding{
	return YES;
}

@end
