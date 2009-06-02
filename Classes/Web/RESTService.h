#import <Foundation/Foundation.h>
#import "WebParams.h"

extern const NSString *WebServiceErrorKey;
extern const NSString *RequestStatusCode;

@protocol RESTServiceDataMapper <NSObject>

- (id)map:(NSData*)data;

@end

@interface RESTService : NSObject {
	NSString *baseUrl;
    id<RESTServiceDataMapper> mapper;
}

- (id)initWithBaseUrl:(NSString*)url;
- (id)initWithBaseUrl:(NSString*)url mapper:(id<RESTServiceDataMapper>)m;
- (id)post:(NSData*)data to:(NSString*)localPath error:(NSError**)error;
- (id)post:(NSData*)data to:(NSString*)localPath headers:(NSDictionary*)headers error:(NSError**)error;
- (id)get:(NSString*)localPath withParams:(WebParams*)params error:(NSError**)error;

@property (readonly, nonatomic) NSString *baseUrl;
                                

@end
