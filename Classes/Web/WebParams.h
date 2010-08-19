#import "FileUpload.h"

@interface WebParams : NSObject {
	NSMutableDictionary *params;
	BOOL multipart;
}
@property (readonly) NSString *queryString;
@property (readonly) NSString *contentType;
@property (readonly) NSData *postData;

+ (WebParams*)params;

- (id)initWithDictionary:(NSDictionary*)dictionary;

- (void)setParam:(id)_param forKey:(id)key;
- (void)addParam:(id)_param forKey:(id)key;

- (NSURL*)appendToURL:(NSURL*)url;

@end
