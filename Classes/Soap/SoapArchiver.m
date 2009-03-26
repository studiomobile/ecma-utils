#import "SoapArchiver.h"
#import "XMLWriter.h"

typedef enum eSAS_tag {
	sasEnvelope,
	sasHeader
} eSAS;

@implementation SoapArchiver
@dynamic message;

-(id)init{
	if(![super init])
		return nil;
	
	
	writer = [[XMLWriter alloc]initWithIndentation:@"\t" lineBreak:@"\n"];
	[writer instruct];
	NSDictionary* attrs = [NSDictionary dictionaryWithObjectsAndKeys:@"http://www.w3.org/2001/XMLSchema-instance", @"xmlns:xsi",
																	@"http://www.w3.org/2001/XMLSchema", @"xmlns:xsd",
																	@"http://schemas.xmlsoap.org/soap/envelope/", @"xmlns",
																	nil];	
	[writer push:@"Envelope" attributes:attrs];
	return self;
}

-(void)dealloc{
	[writer release];	
	[super dealloc];
}

#pragma mark private

-(NSString*)namespaceOf: (id)objv{
	return [objv respondsToSelector:@selector(soapNamespace)] ? [objv performSelector: @selector(soapNamespace)] : nil;
}

-(void)privateEncodeObject: (id)objv forKey:(NSString*)key namespace:(NSString*)ns{
	NSDictionary* attrs = ns ? [NSDictionary dictionaryWithObject: ns forKey: @"xmlns"] : nil;	
	
	if([objv isKindOfClass: [NSString class]]){
		[writer tag:key content:objv attributes: attrs];
	}
	else if([objv isKindOfClass:[NSDate class]]){
		NSDate* date = (NSDate*)objv;
		NSDateFormatter *formatter = [[NSDateFormatter new] autorelease];
		[formatter setDateFormat:@"dd/MM/yyyy"];	
		NSString* dateStr = [formatter stringFromDate:date];
		[writer tag:key content:dateStr attributes: attrs];
	}
	else{
		[writer push: key attributes: attrs];
		[objv encodeWithCoder:self];
		[writer pop];
	}
}


#pragma mark utility

-(void)encodeObject: (id)objv forKey:(NSString*)key namespace:(NSString*)ns{
	if(!hasBody && !state == sasHeader){
		[writer push:@"Body"];
		hasBody = YES;
	}

	[self privateEncodeObject: objv forKey: key namespace: ns];
}

-(void)encodeHeader: (id)objv{
	if(hasHeader || hasBody){		
		return;
	}	
	
	state = sasHeader;
	[self privateEncodeObject:objv forKey:@"Header" namespace: [self namespaceOf: objv]];
	state = sasEnvelope;
	hasHeader = YES; 
}

#pragma mark NSCoder

- (void)encodeObject:(id)objv forKey:(NSString *)key{
	NSString* ns = [self namespaceOf: objv];
	[self encodeObject:objv forKey:key namespace:ns];
}

- (void)encodeBool:(BOOL)boolv forKey:(NSString *)key{
	[writer tag:key content: boolv ? @"true" : @"false"];
}

- (void)encodeInt:(int)intv forKey:(NSString *)key{
	[writer tag:key content: [NSString stringWithFormat:@"%d", intv]];
}

- (void)encodeFloat:(float)realv forKey:(NSString *)key{
	[writer tag:key content: [NSString stringWithFormat:@"%f", realv]];
}

- (void)encodeDouble:(double)realv forKey:(NSString *)key{
	[writer tag:key content: [NSString stringWithFormat:@"%f", realv]];	
}


- (NSInteger)versionForClassName:(NSString *)className{
	return 100000;
}

-(NSString*)message{
	return writer.result;
}


@end
