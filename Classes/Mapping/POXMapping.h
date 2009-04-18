#import <Foundation/Foundation.h>
#import "SelfDescribing.h"
#import "RESTService.h"

enum {
	kPOXElementObject = 1,
	kPOXElementArray = 2,
	kPOXElementProperty = 4,
	kPOXElementPrimitive = 8,
	kPOXElementSkip = 16,
	kPOXElementRoot = 32
};

typedef NSUInteger POXElementType;

struct POXElement {
	id object;
	POXElementType elementType;
	struct POXElement *prev;
};


@interface POXMapping : NSObject <RESTServiceDataMapper> {
	SelfDescribing *result;
	struct POXElement *top;
}

- (SelfDescribing *)result;
- (id)map:(NSData*)data;
+ (POXMapping*)mapper;

@end

