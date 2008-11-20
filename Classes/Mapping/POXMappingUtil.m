#import "POXMappingUtil.h"

@implementation POXPrimitiveHolder

@synthesize value;

- (id)initWithvalue:(NSString*)val {
	if(self = [super init]) {
		self.value = val;
	}
	return self;
}

- (void)dealloc {
	[value release];
	[super dealloc];
}

- (id)realValue {
	return value;
}
@end

@implementation NSNumber(PrimitiveMapping)

+ (id)objFromString:(NSString*)str {
	NSString *lowerCaseStr = [str lowercaseString];
	if([lowerCaseStr isEqualToString:@"true"]) {
		return [NSNumber numberWithBool:YES];
	} else if([lowerCaseStr isEqualToString:@"false"]) {
		return [NSNumber numberWithBool:NO];
	} else {
		return [NSNumber numberWithDouble:[str doubleValue]];	
	}
}

@end

@implementation NSString(PrimitiveMapping)

+ (id)objFromString:(NSString*)str {
	return [NSString stringWithString:str];
}

@end

@implementation POXNumberHolder
- (id)realValue {
	return [NSNumber numberWithDouble:[self.value doubleValue]];
}
@end


