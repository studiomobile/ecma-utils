#import "SoapEntityProto.h"

@class SoapCustomEntity;

@interface SoapRequest : NSObject {
	NSString* url;
	NSString* action;
	SoapCustomEntity* header;
	id<SoapEntityProto> body;
	id responseType;
	BOOL responseIsMany;
	NSArray* pathToResult;
	id result;
	NSError* error;
}

@property(retain) NSString* url;
@property(retain) NSString* action;
@property(retain) SoapCustomEntity* header;
@property(retain) id<SoapEntityProto> body;
@property(retain) id responseType;
@property(assign) BOOL responseIsMany;
@property(retain) NSArray* pathToResult;
@property(retain, readonly)	id result; 
@property(retain, readonly)	NSError* error; 

-(BOOL)execute;

@end

@interface SoapRequest (Async)

-(id)executeAndReturnResultOrError;

@end

