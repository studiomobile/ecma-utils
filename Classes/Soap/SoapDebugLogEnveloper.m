#import "SoapDebugLogEnveloper.h"


@implementation SoapDebugLogEnveloper
@synthesize maxTagLength;

- (id) init{
	self = [super init];
	if (self != nil) {
		maxTagLength = 200;
	}
	return self;
}


- (void)encodeString:(NSString*)str forKey:(NSString *)key attributes: (NSDictionary*)attrs{
	NSString* realStr = str;
	if(str.length > maxTagLength){
		realStr = [str substringToIndex: maxTagLength];
		realStr = [realStr stringByAppendingString: @" ..."];
	}
	[super encodeString:realStr forKey:key attributes:attrs];
}

@end
