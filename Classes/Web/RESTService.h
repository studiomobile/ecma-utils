#import <Foundation/Foundation.h>
#import "WebParams.h"

extern const NSString *WebServiceErrorKey;
extern const NSString *RequestStatusCode;

@protocol RESTServiceDataMapper <NSObject>

- (id)map:(NSData*)data;

@end

@interface RESTService : NSObject {
	NSString *baseUrl;
	NSString *login;
	NSString *password;
    id<RESTServiceDataMapper> mapper;
}
@property (readonly, nonatomic) NSString *baseUrl;
@property (retain) NSString *login;
@property (retain) NSString *password;

- (id)initWithBaseUrl:(NSString*)url;
- (id)initWithBaseUrl:(NSString*)url mapper:(id<RESTServiceDataMapper>)m;
- (id)put:(NSData*)data contentType:(NSString*)contentType to:(NSString*)localPath error:(NSError**)error;
- (id)put:(NSData*)data contentType:(NSString*)contentType to:(NSString*)localPath headers:(NSDictionary*)headers error:(NSError**)error;
- (id)post:(NSData*)data contentType:(NSString*)contentType to:(NSString*)localPath error:(NSError**)error;
- (id)post:(NSData*)data contentType:(NSString*)contentType to:(NSString*)localPath headers:(NSDictionary*)headers error:(NSError**)error;
- (id)get:(NSString*)localPath withParams:(WebParams*)params headers:(NSDictionary*)headers error:(NSError**)error;
- (id)get:(NSString*)localPath withParams:(WebParams*)params error:(NSError**)error;
                                

@end
