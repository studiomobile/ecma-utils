#import "SoapArchiver.h"
#import "XMLWriter.h"

@implementation SoapArchiver
@dynamic result;

-(id)init{
	if(![super init])
		return nil;
	
	writer = [[XMLWriter alloc]initWithIndentation:@"\t" lineBreak:@"\n"];
	[writer instruct];
	NSDictionary* attrs = [NSDictionary dictionaryWithObjectsAndKeys:@"http://www.w3.org/2001/XMLSchema-instance", @"xmlns:xsi",
																	@"http://www.w3.org/2001/XMLSchema", @"xmlns:xsd",
																	@"http://schemas.xmlsoap.org/soap/envelope/", @"xmlns:soap",
																	nil];
	
	[writer push:@"soap:Envelope" attributes:attrs];	
	return self;
}

-(void)dealloc{
	[writer release];	
	[super dealloc];
}


- (void)encodeObject:(id)objv forKey:(NSString *)key{
	if([objv isKindOfClass: [NSString class]]){
		[writer tag:key content:objv];
	}
	else if([objv isKindOfClass:[NSDate class]]){
		NSDate* date = (NSDate*)objv;
		NSDateFormatter *formatter = [[NSDateFormatter new] autorelease];
		[formatter setDateFormat:@"dd/MM/yyyy"];	
		NSString* dateStr = [formatter stringFromDate:date];
		[writer tag:key content:dateStr];
	}
	else{
		[writer push: key];
		[objv encodeWithCoder:self];
		[writer pop];
	}
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

-(NSString*)result{
	return writer.result;
}


@end
