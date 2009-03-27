#import "TouchXML.h";
#import "NSError+Utils.h"
#import "SoapUnarchiver.h"


@interface SoapUnarchiverContext : NSObject
{
	NSDictionary* mappings;
	CXMLNode* node;
	NSDictionary* nodesCache;	
}

@property(assign) NSDictionary* mappings;
@property(assign) CXMLNode* node;
@property(retain) NSDictionary* nodesCache;

+(SoapUnarchiverContext*) contextWithNode: (CXMLNode*)node mappings: (NSDictionary*)mappings;

-(CXMLNode*)nodeNamed: (NSString*)name;

@end

@implementation SoapUnarchiverContext

@synthesize mappings;
@synthesize node;
@synthesize nodesCache;

+(SoapUnarchiverContext*) contextWithNode: (CXMLNode*)_node mappings: (NSDictionary*)_mappings{
	SoapUnarchiverContext* obj = [[self new]autorelease];
	obj.mappings = _mappings;
	obj.node = _node;
	
	return obj;
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

#pragma mark utility

-(NSArray*) decodeObjectsOfType: (Class)aClass forXpath:(NSString*)path namespaceMappings: (NSDictionary*)mappings{
	
	NSError* error = nil;
	NSArray* nodes = [xml nodesForXPath:path namespaceMappings: mappings error:&error];
	if(error){
		@throw error;
	}
	
	NSMutableArray* result = [NSMutableArray array];
	for(CXMLNode* node in nodes){
		self.nodeContext = [SoapUnarchiverContext contextWithNode:node mappings:mappings];
		
		id obj = [[aClass alloc]initWithCoder:self];
		[result addObject:obj];
	}	   
	
	return [result copy];	
}

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


#pragma mark NSCoder

- (id)decodeObjectForKey:(NSString *)key{
	@throw [NSError errorWithDomain:@"SoapUnarchiving" code:1 description: @"decodeObjectForKey: not supported"];
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
