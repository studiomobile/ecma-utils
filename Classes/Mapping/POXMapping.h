#import <Foundation/Foundation.h>

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


@interface POXMapping : NSObject {
	id result;
	struct POXElement *top;
}

- (id)result;

@end

