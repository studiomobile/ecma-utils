#import "SoapEnveloper.h"
#import "SoapEntityProto.h"
#import "XMLWriter.h"
#import "NSError+Utils.h"

typedef enum eSAS_tag {
	sasEnvelope,
	sasHeader
} eSAS;

///////////////////////////////////////////////////////////////////////////
@interface NSObject (SOAP)

-(id)safeGetSoapClass;

@end


@implementation NSObject (SOAP)

-(id)safeGetSoapClass{
	if(![self respondsToSelector:@selector(soapClass)])
		return [self class];
	return [self performSelector:@selector(soapClass)];
}

@end

///////////////////////////////////////////////////////////////////////////
@interface SoapEnveloper ()

-(void)encodeObject: (id)objv forKey:(NSString*)key namespace:(NSString*)ns;

@end


@implementation SoapEnveloper

+(SoapEnveloper*)soapEnveloper{
	return [[[self class]new]autorelease];
}

-(id)init{
	if(![super init])
		return nil;	
	
	writer = [[XMLWriter alloc]initWithIndentation:@"\t" lineBreak:@"\n"];
	[writer instruct];
	NSDictionary* attrs = [NSDictionary dictionaryWithObjectsAndKeys:@"http://www.w3.org/2001/XMLSchema-instance", @"xmlns:xsi",
																	@"http://www.w3.org/2001/XMLSchema", @"xmlns:xsd",
																	@"http://www.w3.org/2003/05/soap-envelope", @"xmlns",
																	nil];	
	[writer openTag:@"Envelope" attributes:attrs];
	return self;
}

-(void)dealloc{
	[writer release];	
	[super dealloc];
}

#pragma mark private

- (void)encodeString:(NSString*)str forKey:(NSString *)key attributes: (NSDictionary*)attrs{
	[writer tag:key content:str attributes: attrs];
}

- (void)encodeDate:(NSDate*)date forKey:(NSString *)key  attributes: (NSDictionary*)attrs{
	NSDateFormatter *formatter = [[NSDateFormatter new] autorelease];
	[formatter setDateFormat:@"yyyy-MM-dd"];	
	NSString* dateStr = [formatter stringFromDate:date];
	[writer tag:key content:dateStr attributes: attrs];	
}

-(void)encodePrimitiveObject: (id)obj ofType: (NSString*)type forKey: (NSString*)key{
	if([type isEqual:@"bool"]){
		[self encodeBool:[obj boolValue] forKey:key];
	}else if([type isEqual:@"int"]){
		[self encodeInt:[obj intValue] forKey:key];
	}else if([type isEqual:@"int32"]){
		[self encodeInt32:[obj intValue] forKey:key];
	}else if([type isEqual:@"int64"]){
		[self encodeInt64:[obj longLongValue] forKey:key];
	}else if([type isEqual:@"float"]){
		[self encodeFloat:[obj floatValue] forKey:key];
	}else if([type isEqual:@"double"]){
		[self encodeDouble:[obj doubleValue] forKey:key];
	}else{
		@throw [NSError errorWithDomain:@"EncodingSoapMessage" code:1 description: [NSString stringWithFormat: @"Invalid primitive type '%@'", type]];			
	}	
}

-(void)encodeCollection: (NSArray*)collection forKey: (NSString*)key{
	id type = [[contextObject safeGetSoapClass] typeForKey:key];
	
	for(id obj in collection){
		if([type isKindOfClass:[NSString class]]){
			[self encodePrimitiveObject:obj ofType:type forKey:key];
		}else{
			[self encodeObject:obj forKey:key];
		}
	}
}

-(void)encodeObject: (id)objv forKey:(NSString*)key namespace:(NSString*)ns{
	NSDictionary* attrs = ns ? [NSDictionary dictionaryWithObject: ns forKey: @"xmlns"] : nil;	
	
	if([objv isKindOfClass: [NSString class]]){
		[self encodeString:objv forKey:key attributes: attrs];
	}
	else if([objv isKindOfClass:[NSDate class]]){
		[self encodeDate: objv forKey: key attributes: attrs];
	}else if([objv isKindOfClass: [NSArray class]]){
		[self encodeCollection: objv forKey: key];
	}else{
		id oldContext = contextObject;
		contextObject = objv;
		[writer openTag: key attributes: attrs];		
		[objv encodeWithCoder:self];
		[writer closeTag];
		contextObject = oldContext;
	}
}

#pragma mark utility

-(void)encodeBodyObject: (id<SoapEntityProto>)objv forKey: (NSString*)key{
	if(state == sasHeader){	
		[writer closeTag];
		state = sasEnvelope;
	}
	
	if(!hasBody){
		[writer openTag:@"Body"];
		hasBody = YES;
	}	
	
	[self encodeObject:objv forKey: key];
}

-(void)encodeBodyObject: (id<SoapEntityProto>)objv{
	[self encodeBodyObject:objv forKey: [[(NSObject*)objv safeGetSoapClass] soapName]];
}

-(void)encodeHeaderObject: (id<SoapEntityProto>)objv forKey: (NSString*)key{
	if(hasBody){		
		@throw [NSError errorWithDomain:@"EncodingSoapMessage" code:2 description:@"encoding header must preceed body"];
	}
	
	if(!hasHeader){
		[writer openTag:@"Header"];
		hasHeader = YES;
	}
	
	state = sasHeader;
	[self encodeObject:objv forKey:key];
}

-(void)encodeHeaderObject: (id<SoapEntityProto>)objv{
	[self encodeHeaderObject:objv forKey: [[(NSObject*)objv safeGetSoapClass] soapName]];
}

#pragma mark NSCoder

- (void)encodeObject:(id)objv{
	NSString* key = [[objv safeGetSoapClass] soapName];
	[self encodeObject:objv forKey: key];
}

- (void)encodeObject:(id)objv forKey:(NSString *)key{
	id type = [objv safeGetSoapClass];	
	NSString* ns = [type respondsToSelector:@selector(soapNamespace)] ? [type soapNamespace] : nil;
	[self encodeObject:objv forKey:key namespace:ns];
}

- (void)encodeBool:(BOOL)boolv forKey:(NSString *)key{
	[writer tag:key content: boolv ? @"true" : @"false"];
}

- (void)encodeInt:(int)intv forKey:(NSString *)key{
	[writer tag:key content: [NSString stringWithFormat:@"%d", intv]];
}

- (void)encodeInt32:(int32_t)intv forKey:(NSString *)key{
	[writer tag:key content: [NSString stringWithFormat:@"%d", intv]];
}

- (void)encodeInt64:(int64_t)intv forKey:(NSString *)key{
	[writer tag:key content: [NSString stringWithFormat:@"%qi", intv]];
}


- (void)encodeFloat:(float)realv forKey:(NSString *)key{
	[writer tag:key content: [NSString stringWithFormat:@"%f", realv]];
}

- (void)encodeDouble:(double)realv forKey:(NSString *)key{
	[writer tag:key content: [NSString stringWithFormat:@"%f", realv]];	
}

- (NSInteger)versionForClassName:(NSString *)className{
	Class c = NSClassFromString(className);
	return [c version];
}

- (BOOL)allowsKeyedCoding{
	return YES;
}

#pragma mark public

-(NSString*)message{
	return writer.result;
}


@end
