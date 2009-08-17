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

- (void)addParam:(id)param forKey:(id)key;

@end
