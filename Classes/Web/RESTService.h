#import <Foundation/Foundation.h>
#import "WebParams.h"

extern const NSString *WebServiceErrorKey;
extern const NSString *RequestStatusCode;

@protocol RESTServiceDataMapper

- (id)map:(NSData*)data;

@end

@interface RESTService : NSObject {
	NSString *baseUrl;
	NSString *login;
	NSString *password;
    NSTimeInterval timeoutInterval;
    NSObject<RESTServiceDataMapper> *mapper;
}
@property (readonly, nonatomic) NSString *baseUrl;
@property (retain) NSString *login;
@property (retain) NSString *password;
@property (assign) NSTimeInterval timeoutInterval;

- (id)initWithBaseUrl:(NSString*)url;
- (id)initWithBaseUrl:(NSString*)url mapper:(NSObject<RESTServiceDataMapper>*)m;
- (id)put:(NSData*)data contentType:(NSString*)contentType to:(NSString*)localPath error:(NSError**)error;
- (id)put:(NSData*)data contentType:(NSString*)contentType to:(NSString*)localPath headers:(NSDictionary*)headers error:(NSError**)error;
- (id)post:(NSData*)data contentType:(NSString*)contentType to:(NSString*)localPath error:(NSError**)error;
- (id)post:(NSData*)data contentType:(NSString*)contentType to:(NSString*)localPath headers:(NSDictionary*)headers error:(NSError**)error;
- (id)get:(NSString*)localPath withParams:(WebParams*)params headers:(NSDictionary*)headers error:(NSError**)error;
- (id)get:(NSString*)localPath withParams:(WebParams*)params error:(NSError**)error;
                                

@end
