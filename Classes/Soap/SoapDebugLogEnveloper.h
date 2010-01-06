#import "SoapEnveloper.h"

@interface SoapDebugLogEnveloper : SoapEnveloper {
	int maxTagLength;
}

@property(assign) int maxTagLength;

@end
