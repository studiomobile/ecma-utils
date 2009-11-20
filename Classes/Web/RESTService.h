#import <Foundation/Foundation.h>
#import "WebParams.h"

extern NSString *const WebServiceErrorKey;
extern NSString *const RequestStatusCode;

@protocol RESTServiceDataMapper

- (id)map:(NSData*)data;

@end

@interface RESTService : NSObject {
	NSString *baseUrl;
	NSString *login;
	NSString *password;
    NSTimeInterval timeoutInterval;
    NSObject<RESTServiceDataMapper> *mapper;
    BOOL enableCookies;
}
@property (readonly, nonatomic) NSString *baseUrl;
@property (retain) NSString *login;
@property (retain) NSString *password;
@property (assign) NSTimeInterval timeoutInterval;
@property (assign) BOOL enableCookies;

- (id)initWithBaseUrl:(NSString*)url;
- (id)initWithBaseUrl:(NSString*)url mapper:(NSObject<RESTServiceDataMapper>*)m;

- (id)put:(NSData*)data contentType:(NSString*)contentType to:(NSString*)localPath error:(NSError**)error;
- (id)put:(NSData*)data contentType:(NSString*)contentType to:(NSString*)localPath headers:(NSDictionary*)headers error:(NSError**)error;

- (id)post:(NSData*)data contentType:(NSString*)contentType to:(NSString*)localPath error:(NSError**)error;
- (id)post:(NSData*)data contentType:(NSString*)contentType to:(NSString*)localPath headers:(NSDictionary*)headers error:(NSError**)error;

- (id)get:(NSString*)localPath withParams:(WebParams*)params headers:(NSDictionary*)headers error:(NSError**)error;
- (id)get:(NSString*)localPath withParams:(WebParams*)params error:(NSError**)error;

- (id)del:(NSString*)localPath withParams:(WebParams*)params error:(NSError**)error; 
- (NSMutableURLRequest*)requestForPath:(NSString*)localPath withParams:(WebParams*)params;

@end
