#import <Foundation/Foundation.h>

extern const NSString *WebServiceErrorKey;
extern const NSString *RequestStatusCode;

@protocol RESTServiceDataMapper

- (id)map:(NSData*)data;

@end

@interface RESTService : NSObject {
	NSString *baseUrl;
    NSString *additionalUrlEncodechars;
    NSObject<RESTServiceDataMapper> *mapper;
}

- (id)initWithBaseUrl:(NSString*)url;
- (id)initWithBaseUrl:(NSString*)url mapper:(NSObject<RESTServiceDataMapper>*)m;
- (id)post:(NSData*)data to:(NSString*)localPath error:(NSError**)error;
- (id)post:(NSData*)data to:(NSString*)localPath headers:(NSDictionary*)headers error:(NSError**)error;
- (id)get:(NSString*)localPath withParams:(NSDictionary*)params error:(NSError**)error;

@property (readonly, nonatomic) NSString *baseUrl;
@property (readwrite, nonatomic, copy) NSString *additionalUrlEncodechars;
                                

@end
