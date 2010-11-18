#import <Foundation/Foundation.h>
#import "SelfDescribing.h"

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


@interface POXMapping : NSObject<NSXMLParserDelegate> {
	SelfDescribing *result;
	struct POXElement *top;
}
@property (nonatomic, readonly) SelfDescribing *result;

+ (POXMapping*)mapper;

- (id)map:(NSData*)data;

@end

